import { useEffect, useState } from 'react'
import { supabase } from './lib/supabase.ts'
import type { Session } from '@supabase/supabase-js'
import './App.css'
import AuthForm from './components/AuthForm.tsx';

function App() {
  const [session, setSession] = useState<Session | null>(null);
  const [errorMessage, setErrorMessage] = useState('');
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    supabase.auth.getSession().then(({ data }) => {
      setSession(data.session);
      setLoading(false)
    });
    const { data: { subscription } } = supabase.auth.onAuthStateChange((_event, newSession) => {
      setSession(newSession)
    })
    return () => subscription.unsubscribe();
  }, []);

  async function signOut() {
    const { error } = await supabase.auth.signOut({ scope: 'local' })
    if (error) {
      setErrorMessage(error.message)
    } else {
      setErrorMessage('')
    }
  };

  return (
    <>
      <section id="center">
        <div className="hero">
        </div>
        <div>
          <h1>Recipe Organizer</h1>
        </div>
        {loading ? <p>Loading...</p> : 
          session ?
          <div>
            <p>{session.user.email}</p>
            <button onClick={() => signOut()}>
            Sign Out </button>
          </div> : <AuthForm /> }
        {errorMessage &&
          <p>{errorMessage}</p>}
      </section>

      <div className="ticks"></div>
    </>
  )
}

export default App
