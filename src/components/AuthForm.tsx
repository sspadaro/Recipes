import { supabase } from '../lib/supabase.ts'
import { useState } from 'react'

function AuthForm() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [errorMessage, setErrorMessage] = useState('');

  async function signUp(newEmail: string, newPassword: string) {
    const { error } = await supabase.auth.signUp({email: newEmail, password: newPassword})
    if (error) {
      setErrorMessage(error.message);
    } else {
      setErrorMessage('');
    }
  };

  async function signIn(newEmail: string, newPassword: string) {
    const { error } = await supabase.auth.signInWithPassword({email: newEmail, password: newPassword})
    if (error) {
      setErrorMessage(error.message);
    } else {
      setErrorMessage('');
    }
  };
  return (
    <form>
      <input type="email" placeholder="Email" value={email} onChange={(e) => 
        setEmail(e.target.value)} />
      <input type="password" placeholder="Password" value={password} onChange={(e) => 
        setPassword(e.target.value)} />
      <button type="button" onClick={() => signUp(email, password)}>Sign Up</button>
      <button type="button" onClick={() => signIn(email, password)}>Sign In</button>
      {errorMessage &&
        <p>{errorMessage}</p>}
    </form>
  )
}

export default AuthForm