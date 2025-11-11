import { useState, useEffect } from 'react'
import Sidebar from './components/Sidebar'
import Overview from './components/Overview'
import Stock from './components/Stock'
import Employees from './components/Employees'
import Finance from './components/Finance'
import Settings from './components/Settings'
import Modal from './components/Modal'
import { closeNUI } from './utils/api'

function App() {
  const [activeTab, setActiveTab] = useState('overview')
  const [business, setBusiness] = useState(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState(null)
  const [isDark, setIsDark] = useState(true)
  const [modal, setModal] = useState(null)

  useEffect(() => {
    // Listen for messages from FiveM
    const handleMessage = (event) => {
      if (event.data.action === 'openDashboard') {
        setBusiness(event.data.data)
        setLoading(false)
        setError(null)
      } else if (event.data.action === 'closeDashboard') {
        closeNUI()
      }
    }

    window.addEventListener('message', handleMessage)

    // Request initial data
    window.postMessage({ action: 'getBusiness' }, '*')

    return () => {
      window.removeEventListener('message', handleMessage)
    }
  }, [])

  const refreshBusiness = async () => {
    if (!business?.id) return
    
    try {
      setLoading(true)
      const { api } = await import('./utils/api')
      const result = await api.getBusiness(business.id)
      if (result.success) {
        setBusiness(result.data)
      }
    } catch (err) {
      console.error('Error refreshing business:', err)
    } finally {
      setLoading(false)
    }
  }

  const handleClose = () => {
    closeNUI()
  }

  if (loading && !business) {
    return (
      <div className="flex items-center justify-center h-screen bg-slate-900">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary-500 mx-auto mb-4"></div>
          <p className="text-slate-400">Loading business data...</p>
        </div>
      </div>
    )
  }

  if (error) {
    return (
      <div className="flex items-center justify-center h-screen bg-slate-900">
        <div className="text-center">
          <p className="text-red-500 mb-4">{error}</p>
          <button
            onClick={handleClose}
            className="px-4 py-2 bg-primary-600 text-white rounded-lg hover:bg-primary-700"
          >
            Close
          </button>
        </div>
      </div>
    )
  }

  if (!business) {
    return (
      <div className="flex items-center justify-center h-screen bg-slate-900">
        <div className="text-center">
          <p className="text-slate-400 mb-4">No business data available</p>
          <button
            onClick={handleClose}
            className="px-4 py-2 bg-primary-600 text-white rounded-lg hover:bg-primary-700"
          >
            Close
          </button>
        </div>
      </div>
    )
  }

  return (
    <div className={`flex h-screen ${isDark ? 'dark' : ''}`}>
      <Sidebar
        activeTab={activeTab}
        setActiveTab={setActiveTab}
        business={business}
        isDark={isDark}
        setIsDark={setIsDark}
        onClose={handleClose}
      />
      <div className="flex-1 overflow-auto bg-slate-900">
        {activeTab === 'overview' && (
          <Overview business={business} refreshBusiness={refreshBusiness} />
        )}
        {activeTab === 'stock' && (
          <Stock business={business} refreshBusiness={refreshBusiness} />
        )}
        {activeTab === 'employees' && (
          <Employees business={business} refreshBusiness={refreshBusiness} setModal={setModal} />
        )}
        {activeTab === 'finance' && (
          <Finance business={business} refreshBusiness={refreshBusiness} setModal={setModal} />
        )}
        {activeTab === 'settings' && (
          <Settings business={business} refreshBusiness={refreshBusiness} setModal={setModal} />
        )}
      </div>
      {modal && (
        <Modal
          {...modal}
          onClose={() => setModal(null)}
        />
      )}
    </div>
  )
}

export default App

