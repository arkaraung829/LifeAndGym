export const metadata = {
  title: 'LifeAndGym API',
  description: 'API backend for LifeAndGym mobile app',
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  );
}
