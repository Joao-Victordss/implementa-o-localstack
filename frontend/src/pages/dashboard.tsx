import { useState, useEffect } from 'react';
import { useRouter } from 'next/router';
import { authService, filesService } from '@/services/api';
import styles from '@/styles/Dashboard.module.css';

interface FileItem {
  key: string;
  name: string;
  size: number;
  lastModified: string;
}

export default function Dashboard() {
  const router = useRouter();
  const [user, setUser] = useState<any>(null);
  const [files, setFiles] = useState<FileItem[]>([]);
  const [uploading, setUploading] = useState(false);
  const [loading, setLoading] = useState(true);
  const [message, setMessage] = useState('');

  useEffect(() => {
    if (!authService.isAuthenticated()) {
      router.push('/login');
      return;
    }

    setUser(authService.getUser());
    loadFiles();
  }, [router]);

  const loadFiles = async () => {
    try {
      const filesList = await filesService.listFiles();
      setFiles(filesList);
    } catch (error) {
      console.error('Erro ao carregar arquivos:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleFileUpload = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;

    setUploading(true);
    setMessage('');

    try {
      await filesService.uploadFile(file);
      setMessage('Arquivo enviado com sucesso!');
      await loadFiles();
      
      // Limpar input
      e.target.value = '';
    } catch (error: any) {
      setMessage(error.response?.data?.message || 'Erro ao enviar arquivo');
    } finally {
      setUploading(false);
    }
  };

  const handleDownload = async (file: FileItem) => {
    try {
      const blob = await filesService.downloadFile(file.key);
      const url = window.URL.createObjectURL(blob);
      const a = document.createElement('a');
      a.href = url;
      a.download = file.name;
      document.body.appendChild(a);
      a.click();
      window.URL.revokeObjectURL(url);
      document.body.removeChild(a);
    } catch (error) {
      alert('Erro ao baixar arquivo');
    }
  };

  const handleDelete = async (file: FileItem) => {
    if (!confirm(`Tem certeza que deseja excluir ${file.name}?`)) return;

    try {
      await filesService.deleteFile(file.key);
      setMessage('Arquivo excluído com sucesso!');
      await loadFiles();
    } catch (error) {
      alert('Erro ao excluir arquivo');
    }
  };

  const handleLogout = () => {
    authService.logout();
    router.push('/login');
  };

  const formatFileSize = (bytes: number) => {
    if (bytes === 0) return '0 Bytes';
    const k = 1024;
    const sizes = ['Bytes', 'KB', 'MB', 'GB'];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    return Math.round(bytes / Math.pow(k, i) * 100) / 100 + ' ' + sizes[i];
  };

  const formatDate = (dateString: string) => {
    return new Date(dateString).toLocaleString('pt-BR');
  };

  if (loading) {
    return (
      <div className={styles.container}>
        <p>Carregando...</p>
      </div>
    );
  }

  return (
    <div className={styles.container}>
      <header className={styles.header}>
        <div>
          <h1>Dashboard</h1>
          <p>Bem-vindo, {user?.name}!</p>
        </div>
        <button onClick={handleLogout} className={styles.logoutButton}>
          Sair
        </button>
      </header>

      <div className={styles.content}>
        <div className={styles.uploadSection}>
          <h2>Upload de Arquivos</h2>
          
          {message && (
            <div className={message.includes('sucesso') ? styles.success : styles.error}>
              {message}
            </div>
          )}

          <div className={styles.uploadBox}>
            <label htmlFor="file-upload" className={styles.uploadLabel}>
              {uploading ? 'Enviando...' : 'Selecionar Arquivo'}
            </label>
            <input
              id="file-upload"
              type="file"
              onChange={handleFileUpload}
              disabled={uploading}
              className={styles.fileInput}
            />
          </div>
        </div>

        <div className={styles.filesSection}>
          <h2>Meus Arquivos ({files.length})</h2>

          {files.length === 0 ? (
            <p className={styles.noFiles}>Nenhum arquivo enviado ainda.</p>
          ) : (
            <div className={styles.filesList}>
              {files.map((file) => (
                <div key={file.key} className={styles.fileItem}>
                  <div className={styles.fileInfo}>
                    <h3>{file.name}</h3>
                    <p>
                      {formatFileSize(file.size)} • {formatDate(file.lastModified)}
                    </p>
                  </div>
                  <div className={styles.fileActions}>
                    <button
                      onClick={() => handleDownload(file)}
                      className={styles.downloadButton}
                    >
                      Download
                    </button>
                    <button
                      onClick={() => handleDelete(file)}
                      className={styles.deleteButton}
                    >
                      Excluir
                    </button>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
