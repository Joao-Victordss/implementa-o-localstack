import { useEffect } from 'react';
import { useRouter } from 'next/router';
import { authService } from '@/services/api';

export default function Home() {
  const router = useRouter();

  useEffect(() => {
    if (authService.isAuthenticated()) {
      router.push('/dashboard');
    } else {
      router.push('/login');
    }
  }, [router]);

  return (
    <div style={{ display: 'flex', justifyContent: 'center', alignItems: 'center', height: '100vh' }}>
      <p>Carregando...</p>
    </div>
  );
}
