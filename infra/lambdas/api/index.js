const { DynamoDBClient, ScanCommand, GetItemCommand, QueryCommand } = require('@aws-sdk/client-dynamodb');

const dynamo = new DynamoDBClient({
  endpoint: process.env.LOCALSTACK_ENDPOINT || 'http://localhost:4566',
  region: process.env.AWS_REGION || 'us-east-1',
  credentials: { accessKeyId: 'test', secretAccessKey: 'test' },
});

const TABLE = process.env.DYNAMODB_TABLE || 'files';

exports.handler = async (event) => {
  console.log('API event', JSON.stringify(event));
  const path = event.path || event.rawPath || '/';
  const method = event.httpMethod || event.requestContext?.http?.method || 'GET';

  if (method === 'GET' && path === '/files') {
    // Simple scan with filters: status and from/to
    const params = {};
    const qs = event.queryStringParameters || {};

    // For simplicity using Scan and doing client-side filter (acceptable for local challenge)
    const cmd = new ScanCommand({ TableName: TABLE });
    const resp = await dynamo.send(cmd);
    let items = (resp.Items || []).map(item => {
      const obj = {};
      for (const k of Object.keys(item)) {
        const v = item[k];
        if (v.S) obj[k] = v.S;
        else if (v.N) obj[k] = Number(v.N);
      }
      return obj;
    });

    if (qs.status) items = items.filter(i => i.status === qs.status);
    if (qs.from || qs.to) {
      const from = qs.from ? new Date(qs.from) : new Date(0);
      const to = qs.to ? new Date(qs.to) : new Date();
      items = items.filter(i => {
        const d = new Date(i.processedAt || 0);
        return d >= from && d <= to;
      });
    }

    // pagination simple
    const limit = Math.min(100, Number(qs.limit || 100));
    const page = Math.max(0, Number(qs.page || 0));
    const start = page * limit;
    const paged = items.slice(start, start + limit);

    return {
      statusCode: 200,
      body: JSON.stringify({ items: paged, total: items.length }),
    };
  }

  // GET /files/{id}
  const m = path.match(/^\/files\/(.+)$/);
  if (method === 'GET' && m) {
    const id = decodeURIComponent(m[1]);
    const pk = id.startsWith('file#') ? id : `file#${id}`;
    const cmd = new GetItemCommand({ TableName: TABLE, Key: { pk: { S: pk } } });
    const resp = await dynamo.send(cmd);
    if (!resp.Item) return { statusCode: 404, body: 'Not found' };

    const obj = {};
    for (const k of Object.keys(resp.Item)) {
      const v = resp.Item[k];
      if (v.S) obj[k] = v.S;
      else if (v.N) obj[k] = Number(v.N);
    }

    return { statusCode: 200, body: JSON.stringify(obj) };
  }

  return { statusCode: 400, body: 'Bad request' };
};
