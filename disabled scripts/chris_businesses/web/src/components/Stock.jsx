import { Package, Plus, AlertTriangle, Search } from 'lucide-react'
import { useState } from 'react'

const Stock = ({ business, refreshBusiness }) => {
  const [searchTerm, setSearchTerm] = useState('')
  const [selectedItem, setSelectedItem] = useState(null)

  const filteredStock = business?.stock?.filter(item =>
    item.name?.toLowerCase().includes(searchTerm.toLowerCase()) ||
    item.label?.toLowerCase().includes(searchTerm.toLowerCase())
  ) || []

  const lowStockItems = filteredStock.filter(item => item.count < 10)

  return (
    <div className="p-6 space-y-6">
      <div className="flex items-center justify-between">
        <h2 className="text-2xl font-bold text-white">Stock Management</h2>
        <button
          className="flex items-center gap-2 px-4 py-2 bg-primary-600 text-white rounded-lg hover:bg-primary-700 transition-colors"
        >
          <Plus className="w-5 h-5" />
          Add Stock
        </button>
      </div>

      {/* Search */}
      <div className="relative">
        <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 w-5 h-5 text-slate-400" />
        <input
          type="text"
          placeholder="Search items..."
          value={searchTerm}
          onChange={(e) => setSearchTerm(e.target.value)}
          className="w-full pl-10 pr-4 py-2 bg-slate-800 border border-slate-700 rounded-lg text-white placeholder-slate-400 focus:outline-none focus:ring-2 focus:ring-primary-500"
        />
      </div>

      {/* Low Stock Alert */}
      {lowStockItems.length > 0 && (
        <div className="bg-yellow-500/10 border border-yellow-500/20 rounded-lg p-4">
          <div className="flex items-center gap-2">
            <AlertTriangle className="w-5 h-5 text-yellow-400" />
            <p className="text-sm text-yellow-400">
              {lowStockItems.length} item(s) are running low on stock
            </p>
          </div>
        </div>
      )}

      {/* Stock List */}
      <div className="bg-slate-800 rounded-lg border border-slate-700 overflow-hidden">
        <div className="p-4 border-b border-slate-700">
          <h3 className="font-semibold text-white">Inventory</h3>
        </div>
        <div className="divide-y divide-slate-700">
          {filteredStock.length > 0 ? (
            filteredStock.map((item, index) => (
              <div
                key={index}
                className="p-4 hover:bg-slate-700/50 transition-colors cursor-pointer"
                onClick={() => setSelectedItem(item)}
              >
                <div className="flex items-center justify-between">
                  <div className="flex items-center gap-3">
                    <div className="p-2 bg-slate-700 rounded-lg">
                      <Package className="w-5 h-5 text-slate-300" />
                    </div>
                    <div>
                      <p className="font-medium text-white">{item.label || item.name}</p>
                      <p className="text-sm text-slate-400">{item.name}</p>
                    </div>
                  </div>
                  <div className="text-right">
                    <p
                      className={`font-semibold ${
                        item.count < 10 ? 'text-red-400' : 'text-green-400'
                      }`}
                    >
                      {item.count || 0} units
                    </p>
                    {item.count < 10 && (
                      <p className="text-xs text-red-400">Low stock</p>
                    )}
                  </div>
                </div>
              </div>
            ))
          ) : (
            <div className="p-8 text-center">
              <Package className="w-12 h-12 text-slate-500 mx-auto mb-3" />
              <p className="text-slate-400">No stock items found</p>
            </div>
          )}
        </div>
      </div>

      {/* Item Details Modal */}
      {selectedItem && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50">
          <div className="bg-slate-800 rounded-lg p-6 max-w-md w-full border border-slate-700">
            <h3 className="text-xl font-bold text-white mb-4">{selectedItem.label}</h3>
            <div className="space-y-3">
              <div>
                <p className="text-sm text-slate-400">Item Name</p>
                <p className="text-white">{selectedItem.name}</p>
              </div>
              <div>
                <p className="text-sm text-slate-400">Quantity</p>
                <p className="text-white">{selectedItem.count || 0} units</p>
              </div>
              {selectedItem.metadata && (
                <div>
                  <p className="text-sm text-slate-400">Metadata</p>
                  <pre className="text-xs text-slate-300 bg-slate-900 p-2 rounded mt-1">
                    {JSON.stringify(selectedItem.metadata, null, 2)}
                  </pre>
                </div>
              )}
            </div>
            <div className="flex gap-3 mt-6">
              <button
                onClick={() => setSelectedItem(null)}
                className="flex-1 px-4 py-2 bg-slate-700 text-white rounded-lg hover:bg-slate-600 transition-colors"
              >
                Close
              </button>
              <button
                className="flex-1 px-4 py-2 bg-primary-600 text-white rounded-lg hover:bg-primary-700 transition-colors"
              >
                Restock
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}

export default Stock

