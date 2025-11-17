import { Settings as SettingsIcon, Edit2, ToggleLeft, ToggleRight, Palette } from 'lucide-react'
import { useState } from 'react'
import { api } from '../utils/api'

const Settings = ({ business, refreshBusiness, setModal }) => {
  const handleUpdateName = () => {
    setModal({
      type: 'input',
      title: 'Update Business Name',
      fields: [
        {
          name: 'name',
          label: 'Business Name',
          type: 'text',
          placeholder: 'Enter new name...',
          defaultValue: business?.name,
          required: true,
        },
      ],
      onSubmit: async (data) => {
        const result = await api.updateSettings(business.id, { name: data.name })
        if (result.success) {
          refreshBusiness()
        }
        return result
      },
    })
  }

  const handleToggleOpen = () => {
    const newStatus = !business?.is_open
    api.updateSettings(business.id, { isOpen: newStatus }).then((result) => {
      if (result.success) {
        refreshBusiness()
      }
    })
  }

  const handleListForSale = () => {
    setModal({
      type: 'input',
      title: 'List Business for Sale',
      fields: [
        {
          name: 'price',
          label: 'Sale Price',
          type: 'number',
          placeholder: 'Enter sale price...',
          required: true,
        },
      ],
      onSubmit: async (data) => {
        const result = await api.sellBusiness(business.id, parseFloat(data.price))
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
        <h2 className="text-2xl font-bold text-white">Business Settings</h2>
      </div>

      {/* General Settings */}
      <div className="bg-slate-800 rounded-lg border border-slate-700 overflow-hidden">
        <div className="p-4 border-b border-slate-700">
          <h3 className="font-semibold text-white">General Settings</h3>
        </div>
        <div className="divide-y divide-slate-700">
          <div className="p-4 flex items-center justify-between">
            <div>
              <p className="font-medium text-white">Business Name</p>
              <p className="text-sm text-slate-400">{business?.name || 'N/A'}</p>
            </div>
            {business?.role === 'owner' && (
              <button
                onClick={handleUpdateName}
                className="flex items-center gap-2 px-3 py-1.5 bg-primary-600 text-white rounded-lg hover:bg-primary-700 transition-colors"
              >
                <Edit2 className="w-4 h-4" />
                Edit
              </button>
            )}
          </div>
          <div className="p-4 flex items-center justify-between">
            <div>
              <p className="font-medium text-white">Business Status</p>
              <p className="text-sm text-slate-400">
                {business?.is_open ? 'Open' : 'Closed'}
              </p>
            </div>
            {business?.role === 'owner' || business?.role === 'manager' ? (
              <button
                onClick={handleToggleOpen}
                className="flex items-center gap-2"
              >
                {business?.is_open ? (
                  <ToggleRight className="w-8 h-8 text-green-400" />
                ) : (
                  <ToggleLeft className="w-8 h-8 text-red-400" />
                )}
              </button>
            ) : null}
          </div>
        </div>
      </div>

      {/* Business Information */}
      <div className="bg-slate-800 rounded-lg border border-slate-700 overflow-hidden">
        <div className="p-4 border-b border-slate-700">
          <h3 className="font-semibold text-white">Business Information</h3>
        </div>
        <div className="p-4 space-y-3">
          <div>
            <p className="text-sm text-slate-400">Business Type</p>
            <p className="text-white capitalize">{business?.business_type || 'N/A'}</p>
          </div>
          <div>
            <p className="text-sm text-slate-400">Owner</p>
            <p className="text-white">{business?.owner_name || 'Unclaimed'}</p>
          </div>
          <div>
            <p className="text-sm text-slate-400">Created</p>
            <p className="text-white">
              {business?.created_at
                ? new Date(business.created_at).toLocaleDateString()
                : 'N/A'}
            </p>
          </div>
        </div>
      </div>

      {/* Owner Actions */}
      {business?.role === 'owner' && (
        <div className="bg-slate-800 rounded-lg border border-slate-700 overflow-hidden">
          <div className="p-4 border-b border-slate-700">
            <h3 className="font-semibold text-white">Owner Actions</h3>
          </div>
          <div className="p-4 space-y-3">
            <button
              onClick={handleListForSale}
              className="w-full flex items-center justify-center gap-2 px-4 py-3 bg-yellow-600 text-white rounded-lg hover:bg-yellow-700 transition-colors"
            >
              <Palette className="w-5 h-5" />
              List Business for Sale
            </button>
          </div>
        </div>
      )}
    </div>
  )
}

export default Settings

