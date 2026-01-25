export default function Home() {
  return (
    <main style={{ padding: '2rem', fontFamily: 'system-ui' }}>
      <h1>LifeAndGym API</h1>
      <p>API backend for the LifeAndGym mobile application.</p>
      <h2>Endpoints</h2>
      <ul>
        <li><code>/api/auth/*</code> - Authentication</li>
        <li><code>/api/gyms/*</code> - Gym management</li>
        <li><code>/api/memberships/*</code> - Memberships & check-ins</li>
        <li><code>/api/workouts/*</code> - Workouts & exercises</li>
        <li><code>/api/classes/*</code> - Classes & bookings</li>
      </ul>
      <p>
        <a href="/api/health">Health Check</a>
      </p>
    </main>
  );
}
