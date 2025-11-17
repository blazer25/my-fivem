import { DollarSign, ArrowDownCircle, ArrowUpCircle, History } from 'lucide-react'
import { useState } from 'react'
import { api } from '../utils/api'

const Finance = ({ business, refreshBusiness, setModal }) => {
  const [transactionFilter, setTransactionFilter] = useState('all')

  const filteredTransactions = business?.transactions?.filter(trans => {
    if (transactionFilter === 'all') return true
    return trans.type === transactionFilter
  }) || []

  const handleDeposit = () => {
    setModal({
      type: 'input',
      title: 'Deposit Money',
      fields: [
        {
          name: 'amount',
          label: 'Amount',
          type: 'number',
          placeholder: 'Enter amount...',
          required: true,
        },
      ],
      onSubmit: async (data) => {
        const result = await api.depositMoney(business.id, parseFloat(data.amount))
        if (result.success) {
          refreshBusiness()
        }
        return result
      },
    })
  }

  const handleWithdraw = () => {
    setModal({
      type: 'input',
      title: 'Withdraw Money',
      fields: [
        {
          name: 'amount',
          label: 'Amount',
          type: 'number',
          placeholder: 'Enter amount...',
          required: true,
        },
      ],
      onSubmit: async (data) => {
        const result = await api.withdrawMoney(business.id, parseFloat(data.amount))
        if (result.success) {
          refreshBusiness()
        }
        return result
      },
    })
  }

  return (
    <div className="p-6 space-y-6">
      <div className="flex items-center justify-between">
        <h2 className="text-2xl font-bold text-white">Financial Management</h2>
      </div>

      {/* Balance Card */}
      <div className="bg-gradient-to-r from-primary-600 to-primary-700 rounded-lg p-6">
        <div className="flex items-center justify-between">
          <div>
            <p className="text-primary-200 text-sm mb-1">Current Balance</p>
            <p className="text-3xl font-bold text-white">
              ${business?.balance?.toLocaleString() || 0}
            </p>
          </div>
          <DollarSign className="w-12 h-12 text-primary-200" />
        </div>
      </div>

      {/* Actions */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        <button
          onClick={handleDeposit}
          className="flex items-center justify-center gap-2 p-4 bg-green-600 text-white rounded-lg hover:bg-green-700 transition-colors"
        >
          <ArrowDownCircle className="w-5 h-5" />
          Deposit Money
        </button>
        <button
          onClick={handleWithdraw}
          className="flex items-center justify-center gap-2 p-4 bg-red-600 text-white rounded-lg hover:bg-red-700 transition-colors"
        >
          <ArrowUpCircle className="w-5 h-5" />
          Withdraw Money
        </button>
      </div>

      {/* Transaction History */}
      <div className="bg-slate-800 rounded-lg border border-slate-700 overflow-hidden">
        <div className="p-4 border-b border-slate-700">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-2">
              <History className="w-5 h-5 text-slate-400" />
              <h3 className="font-semibold text-white">Transaction History</h3>
            </div>
            <select
              value={transactionFilter}
              onChange={(e) => setTransactionFilter(e.target.value)}
              className="px-3 py-1.5 bg-slate-700 border border-slate-600 rounded text-white text-sm focus:outline-none focus:ring-2 focus:ring-primary-500"
            >
              <option value="all">All Transactions</option>
              <option value="deposit">Deposits</option>
              <option value="withdraw">Withdrawals</option>
              <option value="sale">Sales</option>
              <option value="purchase">Purchases</option>
            </select>
          </div>
        </div>
        <div className="divide-y divide-slate-700 max-h-96 overflow-y-auto">
          {filteredTransactions.length > 0 ? (
            filteredTransactions.map((transaction, index) => (
              <div
                key={index}
                className="p-4 hover:bg-slate-700/50 transition-colors"
              >
                <div className="flex items-center justify-between">
                  <div>
                    <p className="font-medium text-white">{transaction.description}</p>
                    <p className="text-sm text-slate-400">
                      {new Date(transaction.timestamp).toLocaleString()}
                    </p>
                    <p className="text-xs text-slate-500 capitalize">{transaction.type}</p>
                  </div>
                  <p
                    className={`font-semibold text-lg ${
                      transaction.type === 'deposit' || transaction.type === 'sale'
                        ? 'text-green-400'
                        : 'text-red-400'
                    }`}
                  >
                    {transaction.type === 'deposit' || transaction.type === 'sale' ? '+' : '-'}
                    ${transaction.amount?.toLocaleString()}
                  </p>
                </div>
              </div>
            ))
          ) : (
            <div className="p-8 text-center">
              <History className="w-12 h-12 text-slate-500 mx-auto mb-3" />
              <p className="text-slate-400">No transactions found</p>
            </div>
          )}
        </div>
      </div>
    </div>
  )
}

export default Finance

