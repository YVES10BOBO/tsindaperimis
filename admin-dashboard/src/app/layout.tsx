import type { Metadata } from 'next';
import './styles.css';

export const metadata: Metadata = {
  title: 'Amategeko Admin',
  description: 'Gucunga amasomo n’ibibazo by’amategeko y’umuhanda.',
};

export default function RootLayout({ children }: Readonly<{ children: React.ReactNode }>) {
  return <html lang="rw"><body>{children}</body></html>;
}
