import { useEffect, useState } from 'react'

const getResourceName = () => {
  return (window.GetParentResourceName && window.GetParentResourceName()) || 'chris_locks'
}

const initialState = {
  visible: false,
  lockId: null,
  title: 'Door Access',
  placeholder: 'Enter code',
  submit: 'Unlock',
  cancel: 'Cancel'
}

export default function App() {
  const [state, setState] = useState(initialState)
  const [value, setValue] = useState('')

  useEffect(() => {
    const handler = (event) => {
      const data = event.data || {}
      if (data.action === 'open') {
        setState({
          visible: true,
          lockId: data.lockId,
          title: data.title || initialState.title,
          placeholder: data.placeholder || initialState.placeholder,
          submit: data.submit || initialState.submit,
          cancel: data.cancel || initialState.cancel
        })
        setValue('')
      } else if (data.action === 'close') {
        setState(initialState)
        setValue('')
      }
    }

    window.addEventListener('message', handler)
    return () => window.removeEventListener('message', handler)
  }, [])

  const handleSubmit = async (event) => {
    event.preventDefault()
    if (!value.trim()) return
    await fetch(`https://${getResourceName()}/submitPassword`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ password: value })
    })
    setValue('')
  }

  const handleCancel = async () => {
    await fetch(`https://${getResourceName()}/cancelPassword`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({})
    })
    setValue('')
  }

  if (!state.visible) return null

  return (
    <div className="lock-overlay">
      <div className="lock-modal">
        <h1>{state.title}</h1>
        <form onSubmit={handleSubmit}>
          <input
            autoFocus
            type="password"
            value={value}
            onChange={(event) => setValue(event.target.value)}
            placeholder={state.placeholder}
            maxLength={32}
          />
          <div className="buttons">
            <button type="submit" className="primary">
              {state.submit}
            </button>
            <button type="button" onClick={handleCancel}>
              {state.cancel}
            </button>
          </div>
        </form>
      </div>
    </div>
  )
}
