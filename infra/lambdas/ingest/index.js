const { S3Client, GetObjectCommand, CopyObjectCommand, DeleteObjectCommand } = require('@aws-sdk/client-s3');
const { DynamoDBClient, PutItemCommand, UpdateItemCommand } = require('@aws-sdk/client-dynamodb');
const crypto = require('crypto');

const LOCALSTACK_ENDPOINT = process.env.LOCALSTACK_ENDPOINT || 'http://localhost:4566';

const s3 = new S3Client({
  endpoint: LOCALSTACK_ENDPOINT,
  region: process.env.AWS_REGION || 'us-east-1',
  credentials: { accessKeyId: 'test', secretAccessKey: 'test' },
  forcePathStyle: true,
});

const dynamo = new DynamoDBClient({
  endpoint: LOCALSTACK_ENDPOINT,
  region: process.env.AWS_REGION || 'us-east-1',
  credentials: { accessKeyId: 'test', secretAccessKey: 'test' },
});

// Helper to stream and compute sha256
async function streamToBuffer(stream) {
  return new Promise((resolve, reject) => {
    const chunks = [];
    stream.on('data', (c) => chunks.push(c));
    stream.on('error', reject);
    stream.on('end', () => resolve(Buffer.concat(chunks)));
  });
}

exports.handler = async (event) => {
  console.log('Event received', JSON.stringify(event));
  for (const record of event.Records || []) {
    try {
      const bucket = record.s3.bucket.name;
      const key = decodeURIComponent(record.s3.object.key.replace(/\+/g, ' '));
      const size = record.s3.object.size;
      const etag = record.s3.object.eTag;

      // Read object
      const getCmd = new GetObjectCommand({ Bucket: bucket, Key: key });
      const getResp = await s3.send(getCmd);
      const bodyBuffer = await streamToBuffer(getResp.Body);

      // Compute checksum
      const checksum = crypto.createHash('sha256').update(bodyBuffer).digest('hex');

      const pk = `file#${key}`;

      // Put initial item with status RAW
      const putCmd = new PutItemCommand({
        TableName: process.env.DYNAMODB_TABLE || 'files',
        Item: {
          pk: { S: pk },
          bucket: { S: bucket },
          key: { S: key },
          size: { N: String(size || bodyBuffer.length) },
          etag: { S: etag || '' },
          status: { S: 'RAW' },
          checksum: { S: checksum },
        },
      });
      await dynamo.send(putCmd);

      // Copy to processed bucket (or same bucket under processed/ prefix)
      const processedBucket = process.env.PROCESSED_BUCKET || 'ingestor-processed';
      const processedKey = `processed/${key}`;

      const copyCmd = new CopyObjectCommand({
        Bucket: processedBucket,
        CopySource: `${bucket}/${key}`,
        Key: processedKey,
      });
      await s3.send(copyCmd);

      // Delete original
      const delCmd = new DeleteObjectCommand({ Bucket: bucket, Key: key });
      await s3.send(delCmd);

      // Update Dynamo item to PROCESSED and set processedAt
      const updateCmd = new UpdateItemCommand({
        TableName: process.env.DYNAMODB_TABLE || 'files',
        Key: { pk: { S: pk } },
        UpdateExpression: 'SET #s = :s, processedAt = :p, bucket = :b, #k = :k',
        ExpressionAttributeNames: { '#s': 'status', '#k': 'key' },
        ExpressionAttributeValues: {
          ':s': { S: 'PROCESSED' },
          ':p': { S: new Date().toISOString() },
          ':b': { S: processedBucket },
          ':k': { S: processedKey },
        },
      });
      await dynamo.send(updateCmd);

      console.log(`Processed ${key} -> ${processedBucket}/${processedKey}`);
    } catch (err) {
      console.error('Failed processing record', err);
      throw err;
    }
  }

  return { statusCode: 200 };
};
