import { TrendingUp, Users, Package, DollarSign, AlertCircle } from 'lucide-react'
import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer } from 'recharts'

const Overview = ({ business, refreshBusiness }) => {
  // Mock data for chart (would come from business data)
  const profitData = [
    { day: 'Mon', profit: 1200 },
    { day: 'Tue', profit: 1900 },
    { day: 'Wed', profit: 1500 },
    { day: 'Thu', profit: 2100 },
    { day: 'Fri', profit: 1800 },
    { day: 'Sat', profit: 2500 },
    { day: 'Sun', profit: 2200 },
  ]

  const stats = [
    {
      label: 'Balance',
      value: `$${business?.balance?.toLocaleString() || 0}`,
      icon: DollarSign,
      color: 'text-green-400',
      bgColor: 'bg-green-400/10',
    },
    {
      label: 'Employees',
      value: business?.employees?.length || 0,
      icon: Users,
      color: 'text-blue-400',
      bgColor: 'bg-blue-400/10',
    },
    {
      label: 'Stock Items',
      value: business?.stock?.length || 0,
      icon: Package,
      color: 'text-purple-400',
      bgColor: 'bg-purple-400/10',
    },
    {
      label: 'Status',
      value: business?.is_open ? 'Open' : 'Closed',
      icon: TrendingUp,
      color: business?.is_open ? 'text-green-400' : 'text-red-400',
      bgColor: business?.is_open ? 'bg-green-400/10' : 'bg-red-400/10',
    },
  ]

  // Check for low stock
  const lowStockItems = business?.stock?.filter(item => item.count < 10) || []

  return (
    <div className="p-6 space-y-6">
      <div className="flex items-center justify-between">
        <h2 className="text-2xl font-bold text-white">Overview</h2>
        <button
          onClick={refreshBusiness}
          className="px-4 py-2 bg-primary-600 text-white rounded-lg hover:bg-primary-700 transition-colors"
        >
          Refresh
        </button>
      </div>

      {/* Stats Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
        {stats.map((stat, index) => {
          const Icon = stat.icon
          return (
            <div
              key={index}
              className={`${stat.bgColor} rounded-lg p-4 border border-slate-700`}
            >
              <div className="flex items-center justify-between mb-2">
                <Icon className={`w-6 h-6 ${stat.color}`} />
              </div>
              <p className="text-sm text-slate-400 mb-1">{stat.label}</p>
              <p className={`text-2xl font-bold ${stat.color}`}>{stat.value}</p>
            </div>
          )
        })}
      </div>

      {/* Alerts */}
      {lowStockItems.length > 0 && (
        <div className="bg-yellow-500/10 border border-yellow-500/20 rounded-lg p-4">
          <div className="flex items-center gap-2 mb-2">
            <AlertCircle className="w-5 h-5 text-yellow-400" />
            <h3 className="font-semibold text-yellow-400">Low Stock Alert</h3>
          </div>
          <p className="text-sm text-slate-300">
            {lowStockItems.length} item(s) are running low on stock
          </p>
        </div>
      )}

      {/* Profit Chart */}
      <div className="bg-slate-800 rounded-lg p-6 border border-slate-700">
        <h3 className="text-lg font-semibold text-white mb-4">Weekly Profit</h3>
        <ResponsiveContainer width="100%" height={300}>
          <LineChart data={profitData}>
            <CartesianGrid strokeDasharray="3 3" stroke="#334155" />
            <XAxis dataKey="day" stroke="#94a3b8" />
            <YAxis stroke="#94a3b8" />
            <Tooltip
              contentStyle={{
                backgroundColor: '#1e293b',
                border: '1px solid #334155',
                borderRadius: '8px',
              }}
            />
            <Line
              type="monotone"
              dataKey="profit"
              stroke="#0ea5e9"
              strokeWidth={2}
              dot={{ fill: '#0ea5e9' }}
            />
          </LineChart>
        </ResponsiveContainer>
      </div>

      {/* Recent Transactions */}
      <div className="bg-slate-800 rounded-lg p-6 border border-slate-700">
        <h3 className="text-lg font-semibold text-white mb-4">Recent Transactions</h3>
        <div className="space-y-2">
          {business?.transactions?.slice(0, 5).map((transaction, index) => (
            <div
              key={index}
              className="flex items-center justify-between p-3 bg-slate-900 rounded-lg"
            >
              <div>
                <p className="text-sm font-medium text-white">{transaction.description}</p>
                <p className="text-xs text-slate-400">
                  {new Date(transaction.timestamp).toLocaleString()}
                </p>
              </div>
              <p
                className={`font-semibold ${
                  transaction.type === 'deposit' || transaction.type === 'sale'
                    ? 'text-green-400'
                    : 'text-red-400'
                }`}
              >
                {transaction.type === 'deposit' || transaction.type === 'sale' ? '+' : '-'}
                ${transaction.amount?.toLocaleString()}
              </p>
            </div>
          )) || (
            <p className="text-slate-400 text-center py-4">No transactions yet</p>
          )}
        </div>
      </div>
    </div>
  )
}

export default Overview

