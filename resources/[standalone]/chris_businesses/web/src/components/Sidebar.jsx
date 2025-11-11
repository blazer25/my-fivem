import { LayoutDashboard, Package, Users, DollarSign, Settings, X, Moon, Sun } from 'lucide-react'

const Sidebar = ({ activeTab, setActiveTab, business, isDark, setIsDark, onClose }) => {
  const tabs = [
    { id: 'overview', label: 'Overview', icon: LayoutDashboard },
    { id: 'stock', label: 'Stock', icon: Package },
    { id: 'employees', label: 'Employees', icon: Users },
    { id: 'finance', label: 'Finance', icon: DollarSign },
    { id: 'settings', label: 'Settings', icon: Settings },
  ]

  return (
    <div className="w-64 bg-slate-800 border-r border-slate-700 flex flex-col">
      {/* Header */}
      <div className="p-4 border-b border-slate-700">
        <div className="flex items-center justify-between mb-2">
          <h1 className="text-xl font-bold text-white">Business Hub</h1>
          <button
            onClick={onClose}
            className="p-1 hover:bg-slate-700 rounded transition-colors"
          >
            <X className="w-5 h-5 text-slate-400" />
          </button>
        </div>
        <div className="mt-2">
          <p className="text-sm font-semibold text-white">{business?.label || 'Business'}</p>
          <p className="text-xs text-slate-400">{business?.business_type || 'General'}</p>
        </div>
      </div>

      {/* Navigation */}
      <nav className="flex-1 p-2">
        {tabs.map((tab) => {
          const Icon = tab.icon
          const isActive = activeTab === tab.id
          return (
            <button
              key={tab.id}
              onClick={() => setActiveTab(tab.id)}
              className={`w-full flex items-center gap-3 px-3 py-2 rounded-lg mb-1 transition-colors ${
                isActive
                  ? 'bg-primary-600 text-white'
                  : 'text-slate-300 hover:bg-slate-700 hover:text-white'
              }`}
            >
              <Icon className="w-5 h-5" />
              <span className="font-medium">{tab.label}</span>
            </button>
          )
        })}
      </nav>

      {/* Footer */}
      <div className="p-4 border-t border-slate-700">
        <div className="flex items-center justify-between mb-2">
          <span className="text-sm text-slate-400">Theme</span>
          <button
            onClick={() => setIsDark(!isDark)}
            className="p-2 hover:bg-slate-700 rounded transition-colors"
          >
            {isDark ? (
              <Sun className="w-5 h-5 text-slate-400" />
            ) : (
              <Moon className="w-5 h-5 text-slate-400" />
            )}
          </button>
        </div>
        {business?.role && (
          <div className="mt-2">
            <span className="text-xs text-slate-500">Role: </span>
            <span className="text-xs font-semibold text-primary-400 capitalize">
              {business.role}
            </span>
          </div>
        )}
      </div>
    </div>
  )
}

export default Sidebar

