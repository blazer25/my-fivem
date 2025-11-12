import { useEffect, useMemo, useState } from 'react'

const getResourceName = () => {
  return (window.GetParentResourceName && window.GetParentResourceName()) || 'chris_locks'
}

const resourceName = getResourceName()

const initialPasswordState = {
  visible: false,
  lockId: null,
  title: 'Door Access',
  placeholder: 'Enter access code...',
  submit: 'Unlock',
  cancel: 'Cancel'
}

const lockTypeOptions = [
  { value: 'password', label: 'Password', credential: 'Password / PIN' },
  { value: 'item', label: 'Item', credential: 'Item name' },
  { value: 'job', label: 'Job / Gang', credential: 'Jobs or gangs (comma separated)' },
  { value: 'owner', label: 'Owner', credential: 'Owner identifier' }
]

const initialForm = {
  id: '',
  type: 'password',
  credential: '',
  targetDoorId: '',
  coords: { x: '', y: '', z: '' },
  radius: '2.5',
  unlockDuration: '300',
  hidden: true,
  useDoor: false,
  doubleDoor: false,
  newDoor: null
}

const buildInitialForm = () => ({
  ...initialForm,
  coords: { ...initialForm.coords },
  newDoor: null
})

const fetchNui = async (event, data) => {
  try {
    const response = await fetch(`https://${resourceName}/${event}`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(data ?? {})
    })
    const text = await response.text()
    if (!text) return null
    return JSON.parse(text)
  } catch (error) {
    return null
  }
}

function PasswordModal({ state, value, setValue }) {
  if (!state.visible) return null

  const handleSubmit = async (event) => {
    event.preventDefault()
    if (!value.trim()) return
    await fetch(`https://${resourceName}/submitPassword`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ password: value })
    })
    setValue('')
  }

  const handleCancel = async () => {
    await fetch(`https://${resourceName}/cancelPassword`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({})
    })
    setValue('')
  }

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

function StatusBanner({ status }) {
  if (!status) return null
  return <div className={`admin-banner ${status.type}`}>{status.text}</div>
}

function AdminPanel({ visible, doorSelection }) {
  const [locks, setLocks] = useState([])
  const [filter, setFilter] = useState('')
  const [selectedId, setSelectedId] = useState(null)
  const [passwordEdit, setPasswordEdit] = useState('')
  const [form, setForm] = useState(() => buildInitialForm())
  const [status, setStatus] = useState(null)
  const [doorLabel, setDoorLabel] = useState('')
  const [loading, setLoading] = useState(false)
  const [creating, setCreating] = useState(false)
  const [updating, setUpdating] = useState(false)

  useEffect(() => {
    if (!visible) return
    const loadLocks = async () => {
      setLoading(true)
      const result = await fetchNui('locksAdmin:getLocks')
      setLoading(false)
      if (!result) {
        setStatus({ type: 'error', text: 'Unable to load locks.' })
        return
      }
      if (result.error) {
        setStatus({ type: 'error', text: result.error })
        return
      }
      setLocks(result.locks || [])
      if (result.locks && result.locks.length > 0) {
        const first = result.locks.find((lock) => lock.id === selectedId) || result.locks[0]
        setSelectedId(first.id)
        setPasswordEdit(first.password || '')
      }
    }

    loadLocks()
  }, [visible])

  useEffect(() => {
    if (!doorSelection) return
    const coords = doorSelection.coords || {}
    const format = (value) => {
      const number = Number(value)
      return Number.isFinite(number) ? number.toFixed(2) : ''
    }
    setForm((prev) => ({
      ...prev,
      targetDoorId: doorSelection.doorId || '',
      useDoor: true,
      coords: {
        x: format(coords.x),
        y: format(coords.y),
        z: format(coords.z)
      },
      radius:
        doorSelection.radius !== undefined && doorSelection.radius !== null
          ? String(doorSelection.radius)
          : prev.radius,
      newDoor: doorSelection.newDoor || null,
      doubleDoor: doorSelection.newDoor ? !!doorSelection.newDoor.double : false
    }))
    const labelText = doorSelection.label || doorSelection.doorId || (doorSelection.newDoor ? 'Custom door' : '')
    setDoorLabel(labelText)
    setStatus({
      type: 'success',
      text: doorSelection.newDoor
        ? `Captured custom ${doorSelection.newDoor.double ? 'double ' : ''}door`
        : `Selected door ${doorSelection.doorId || ''}`
    })
    const timeout = setTimeout(() => setStatus(null), 3500)
    return () => clearTimeout(timeout)
  }, [doorSelection])

  const selectedLock = useMemo(() => locks.find((lock) => lock.id === selectedId) || null, [locks, selectedId])

  const filteredLocks = useMemo(() => {
    if (!filter.trim()) return locks
    const query = filter.trim().toLowerCase()
    return locks.filter((lock) => {
      return (
        (lock.id && lock.id.toLowerCase().includes(query)) ||
        (lock.targetDoorId && lock.targetDoorId.toLowerCase().includes(query)) ||
        (lock.ownerIdentifier && lock.ownerIdentifier.toLowerCase().includes(query))
      )
    })
  }, [locks, filter])

  const notify = (type, text) => {
    setStatus({ type, text })
    setTimeout(() => setStatus(null), 3500)
  }

  const refreshLocks = async (preserveId) => {
    setLoading(true)
    const result = await fetchNui('locksAdmin:getLocks')
    setLoading(false)
    if (!result) {
      notify('error', 'Unable to reload locks.')
      return
    }
    if (result.error) {
      notify('error', result.error)
      return
    }
    setLocks(result.locks || [])
    if (preserveId) {
      const next = (result.locks || []).find((lock) => lock.id === preserveId)
      setSelectedId(next ? next.id : null)
      setPasswordEdit(next && next.password ? next.password : '')
    }
  }

  const handleSelectLock = (lock) => {
    setSelectedId(lock.id)
    setPasswordEdit(lock.password || '')
  }

  const handleTeleport = async (lock) => {
    await fetchNui('locksAdmin:teleport', { id: lock.id })
    notify('inform', `Teleporting to ${lock.id}...`)
  }

  const handleRemove = async (lock) => {
    const result = await fetchNui('locksAdmin:removeLock', { id: lock.id })
    if (!result) {
      notify('error', 'Failed to remove lock.')
      return
    }
    if (result.success) {
      notify('success', result.message || `Removed ${lock.id}.`)
      await refreshLocks()
    } else {
      notify('error', result.message || 'Failed to remove lock.')
    }
  }

  const handleSelectDoor = async () => {
    await fetchNui('locksAdmin:startDoorSelect', { doubleDoor: form.doubleDoor })
    setForm((prev) => ({ ...prev, newDoor: null }))
  }

  const handleUpdatePassword = async () => {
    if (!selectedLock || selectedLock.type !== 'password') return
    setUpdating(true)
    const result = await fetchNui('locksAdmin:updatePassword', {
      id: selectedLock.id,
      password: passwordEdit.trim()
    })
    setUpdating(false)
    if (!result) {
      notify('error', 'Failed to update password.')
      return
    }
    if (result.success) {
      notify('success', result.message || 'Password updated.')
      await refreshLocks(selectedLock.id)
    } else {
      notify('error', result.message || 'Failed to update password.')
    }
  }

  const handleDoorLookup = async () => {
    if (!form.targetDoorId.trim()) {
      notify('error', 'Enter a door ID or uncheck "Use door coordinates" to create a standalone lock.')
      return
    }
    const result = await fetchNui('locksAdmin:getDoorInfo', { doorId: form.targetDoorId.trim() })
    if (!result || !result.coords) {
      notify('error', 'Door not found.')
      return
    }
    const coords = result.coords
    const format = (value) => {
      const number = Number(value)
      return Number.isFinite(number) ? number.toFixed(2) : ''
    }
    setForm((prev) => ({
      ...prev,
      coords: { x: format(coords.x), y: format(coords.y), z: format(coords.z) },
      newDoor: null,
      doubleDoor: !!result.doors
    }))
    setDoorLabel(result.label || result.id || form.targetDoorId.trim())
    notify('success', 'Door coordinates loaded.')
  }

  const handleCreateLock = async (event) => {
    event.preventDefault()
    if (!form.id.trim()) {
      notify('error', 'Lock ID is required.')
      return
    }
    if (!form.type) {
      notify('error', 'Lock type is required.')
      return
    }
    const hasDoorId = !!form.targetDoorId.trim()
    const hasCustomDoor = !!form.newDoor
    const coordsFilled = ['x', 'y', 'z'].every((axis) => form.coords[axis] !== '')
    const usingDoorData = form.useDoor && (hasDoorId || hasCustomDoor)
    if (!usingDoorData && !coordsFilled) {
      notify('error', 'Provide coordinates or select a door before creating the lock.')
      return
    }
    const radius = parseFloat(form.radius)
    const unlockDuration = parseInt(form.unlockDuration, 10)
    const payload = {
      id: form.id.trim(),
      type: form.type,
      credential: form.credential.trim(),
      radius: Number.isFinite(radius) ? radius : undefined,
      unlockDuration: Number.isFinite(unlockDuration) ? unlockDuration : undefined,
      hidden: form.hidden
    }
    if (usingDoorData) {
      if (hasDoorId) {
        payload.targetDoorId = form.targetDoorId.trim()
      }
      if (hasCustomDoor) {
        payload.newDoor = form.newDoor
      }
    } else {
      payload.coords = {
        x: parseFloat(form.coords.x),
        y: parseFloat(form.coords.y),
        z: parseFloat(form.coords.z)
      }
      payload.useDoor = false
      payload.targetDoorId = undefined
    }
    setCreating(true)
    const result = await fetchNui('locksAdmin:createLock', payload)
    setCreating(false)
    if (!result) {
      notify('error', 'Failed to create lock.')
      return
    }
    if (result.success) {
      notify('success', result.message || `Lock ${payload.id} created.`)
      setForm(buildInitialForm())
      setDoorLabel('')
      await refreshLocks(payload.id)
    } else {
      notify('error', result.message || 'Failed to create lock.')
    }
  }

  const handleClose = async () => {
    await fetchNui('locksAdmin:close')
  }

  const typeMeta = lockTypeOptions.find((option) => option.value === form.type) || lockTypeOptions[0]
  const shouldShowCoords = !form.useDoor || (!form.targetDoorId.trim() && !form.newDoor)

  if (!visible) return null

  return (
    <div className="lock-overlay admin-overlay">
      <div className="admin-shell">
        <div className="admin-header">
          <div>
            <h1>Locks Administration</h1>
            <p>Manage doors for real estate agents and admins</p>
          </div>
          <div className="admin-actions">
            <button className="admin-button ghost" onClick={() => refreshLocks(selectedId)} disabled={loading}>
              {loading ? 'Refreshing...' : 'Refresh'}
            </button>
            <button className="admin-button ghost" onClick={handleClose}>
              Close
            </button>
          </div>
        </div>

        <StatusBanner status={status} />

        <div className="admin-body">
          <div className="admin-list">
            <div className="list-toolbar">
              <input
                className="admin-input"
                placeholder="Filter by lock ID, door, or owner..."
                value={filter}
                onChange={(event) => setFilter(event.target.value)}
              />
              <span className="list-count">{filteredLocks.length} locks</span>
            </div>
            <div className="table-wrapper">
              <table className="lock-table">
                <thead>
                  <tr>
                    <th>ID</th>
                    <th>Type</th>
                    <th>Password / Owner</th>
                    <th>Door</th>
                    <th>Actions</th>
                  </tr>
                </thead>
                <tbody>
                  {filteredLocks.map((lock) => (
                    <tr
                      key={lock.id}
                      className={selectedId === lock.id ? 'selected' : ''}
                      onClick={() => handleSelectLock(lock)}
                    >
                      <td>{lock.id}</td>
                      <td>
                        <span className={`tag tag-${lock.type}`}>{lock.type}</span>
                      </td>
                      <td>{lock.type === 'password' ? lock.password || '—' : lock.ownerIdentifier || '—'}</td>
                      <td>{lock.targetDoorId || '—'}</td>
                      <td className="row-actions">
                        <button
                          className="admin-button tiny"
                          onClick={(event) => {
                            event.stopPropagation()
                            handleTeleport(lock)
                          }}
                        >
                          Teleport
                        </button>
                        <button
                          className="admin-button tiny ghost"
                          onClick={(event) => {
                            event.stopPropagation()
                            handleRemove(lock)
                          }}
                        >
                          Remove
                        </button>
                      </td>
                    </tr>
                  ))}
                  {filteredLocks.length === 0 && (
                    <tr>
                      <td colSpan={5} className="empty-row">
                        {loading ? 'Loading locks...' : 'No locks found.'}
                      </td>
                    </tr>
                  )}
                </tbody>
              </table>
            </div>
          </div>

          <div className="admin-detail">
            {selectedLock ? (
              <div className="detail-card">
                <h2>Lock Details</h2>
                <div className="detail-grid">
                  <div>
                    <label>Lock ID</label>
                    <div className="detail-value">{selectedLock.id}</div>
                  </div>
                  <div>
                    <label>Type</label>
                    <div className="detail-value">{selectedLock.type}</div>
                  </div>
                  <div>
                    <label>Owner / Identifier</label>
                    <div className="detail-value">{selectedLock.ownerIdentifier || '—'}</div>
                  </div>
                  <div>
                    <label>Door ID</label>
                    <div className="detail-value">{selectedLock.targetDoorId || '—'}</div>
                  </div>
                  <div>
                    <label>Coordinates</label>
                    <div className="detail-value">
                      {(() => {
                        const coords = selectedLock.coords || { x: 0, y: 0, z: 0 }
                        const format = (value) => {
                          const number = Number(value)
                          return Number.isFinite(number) ? number.toFixed(2) : '0.00'
                        }
                        return `${format(coords.x)}, ${format(coords.y)}, ${format(coords.z)}`
                      })()}
                    </div>
                  </div>
                </div>

                {selectedLock.type === 'password' && (
                  <div className="password-editor">
                    <label>Change Password</label>
                    <div className="password-row">
                      <input
                        className="admin-input"
                        value={passwordEdit}
                        maxLength={32}
                        placeholder="New password or leave blank to clear"
                        onChange={(event) => setPasswordEdit(event.target.value)}
                      />
                      <button className="admin-button" onClick={handleUpdatePassword} disabled={updating}>
                        {updating ? 'Saving...' : 'Save'}
                      </button>
                    </div>
                  </div>
                )}
              </div>
            ) : (
              <div className="detail-empty">Select a lock to view details.</div>
            )}

            <div className="create-card">
              <h2>Create Lock</h2>
              <form onSubmit={handleCreateLock} className="create-form">
                <div className="form-grid">
                  <div className="form-item">
                    <label>Lock ID</label>
                    <input
                      className="admin-input"
                      value={form.id}
                      onChange={(event) => setForm({ ...form, id: event.target.value })}
                      placeholder="Unique identifier"
                    />
                  </div>
                  <div className="form-item">
                    <label>Type</label>
                    <select
                      className="admin-input"
                      value={form.type}
                      onChange={(event) => setForm({ ...form, type: event.target.value })}
                    >
                      {lockTypeOptions.map((option) => (
                        <option key={option.value} value={option.value}>
                          {option.label}
                        </option>
                      ))}
                    </select>
                  </div>
                  <div className="form-item">
                    <label>{typeMeta.credential}</label>
                    <input
                      className="admin-input"
                      value={form.credential}
                      onChange={(event) => setForm({ ...form, credential: event.target.value })}
                      placeholder={typeMeta.credential}
                    />
                  </div>
                  <div className="form-item">
                    <label>Door ID</label>
                    <input
                      className="admin-input"
                      value={form.targetDoorId}
                      onChange={(event) => setForm({ ...form, targetDoorId: event.target.value })}
                      placeholder="ox_doorlock door name"
                    />
                    <div className="door-actions">
                      <label className="checkbox">
                        <input
                          type="checkbox"
                          checked={form.useDoor}
                          onChange={(event) =>
                            setForm((prev) => {
                              const nextUseDoor = event.target.checked
                              return {
                                ...prev,
                                useDoor: nextUseDoor,
                                targetDoorId: nextUseDoor ? prev.targetDoorId : '',
                                newDoor: nextUseDoor ? prev.newDoor : null
                              }
                            })
                          }
                        />
                        Use door coordinates
                      </label>
                      <label className="checkbox">
                        <input
                          type="checkbox"
                          checked={form.doubleDoor}
                          onChange={(event) => setForm({ ...form, doubleDoor: event.target.checked })}
                        />
                        Double door
                      </label>
                      <button
                        type="button"
                        className="admin-button tiny ghost"
                        onClick={handleDoorLookup}
                        disabled={!form.targetDoorId.trim()}
                      >
                        Fetch door
                      </button>
                      <button type="button" className="admin-button tiny" onClick={handleSelectDoor}>
                        Select door in world
                      </button>
                    </div>
                    {doorLabel && <span className="door-label">{doorLabel}</span>}
                    {form.newDoor && (
                      <div className="door-summary">
                        <strong>Captured:</strong>{' '}
                        {form.newDoor.double ? 'Double door' : 'Single door'} · Model{' '}
                        {form.newDoor.doors
                          ?.map((door) =>
                            typeof door.model === 'number'
                              ? `0x${door.model.toString(16).toUpperCase()}`
                              : String(door.model)
                          )
                          .join(', ')}
                      </div>
                    )}
                  </div>
                  {shouldShowCoords && (
                    <div className="form-item coordinates">
                      <label>Coordinates</label>
                      <div className="coord-grid">
                        <input
                          className="admin-input"
                          value={form.coords.x}
                          onChange={(event) => setForm({ ...form, coords: { ...form.coords, x: event.target.value } })}
                          placeholder="X"
                        />
                        <input
                          className="admin-input"
                          value={form.coords.y}
                          onChange={(event) => setForm({ ...form, coords: { ...form.coords, y: event.target.value } })}
                          placeholder="Y"
                        />
                        <input
                          className="admin-input"
                          value={form.coords.z}
                          onChange={(event) => setForm({ ...form, coords: { ...form.coords, z: event.target.value } })}
                          placeholder="Z"
                        />
                      </div>
                    </div>
                  )}
                  <div className="form-item">
                    <label>Radius</label>
                    <input
                      className="admin-input"
                      type="number"
                      min="0.5"
                      step="0.1"
                      value={form.radius}
                      onChange={(event) => setForm({ ...form, radius: event.target.value })}
                    />
                  </div>
                  <div className="form-item">
                    <label>Unlock Duration (seconds)</label>
                    <input
                      className="admin-input"
                      type="number"
                      min="0"
                      step="30"
                      value={form.unlockDuration}
                      onChange={(event) => setForm({ ...form, unlockDuration: event.target.value })}
                    />
                  </div>
                  <div className="form-item checkbox-only">
                    <label className="checkbox">
                      <input
                        type="checkbox"
                        checked={form.hidden}
                        onChange={(event) => setForm({ ...form, hidden: event.target.checked })}
                      />
                      Hidden interaction
                    </label>
                  </div>
                </div>
                <button className="admin-button submit" type="submit" disabled={creating}>
                  {creating ? 'Creating...' : 'Create Lock'}
                </button>
              </form>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}

export default function App() {
  const [passwordState, setPasswordState] = useState(initialPasswordState)
  const [passwordValue, setPasswordValue] = useState('')
  const [adminVisible, setAdminVisible] = useState(false)
  const [doorSelection, setDoorSelection] = useState(null)

  useEffect(() => {
    const handler = (event) => {
      const data = event.data || {}
      if (data.action === 'open') {
        setPasswordState({
          visible: true,
          lockId: data.lockId,
          title: data.title || initialPasswordState.title,
          placeholder: data.placeholder || initialPasswordState.placeholder,
          submit: data.submit || initialPasswordState.submit,
          cancel: data.cancel || initialPasswordState.cancel
        })
        setPasswordValue('')
      } else if (data.action === 'close') {
        setPasswordState(initialPasswordState)
        setPasswordValue('')
      } else if (data.action === 'openAdmin') {
        setAdminVisible(true)
      } else if (data.action === 'closeAdmin') {
        setAdminVisible(false)
      } else if (data.action === 'doorSelected') {
        setAdminVisible(true)
        setDoorSelection({
          doorId: data.doorId,
          label: data.label,
          coords: data.coords,
          radius: data.radius,
          newDoor: data.newDoor || null,
          at: Date.now()
        })
      }
    }

    window.addEventListener('message', handler)
    return () => window.removeEventListener('message', handler)
  }, [])

  return (
    <>
      <PasswordModal state={passwordState} value={passwordValue} setValue={setPasswordValue} />
      <AdminPanel visible={adminVisible} doorSelection={doorSelection} />
    </>
  )
}
