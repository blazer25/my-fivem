import { Users, UserPlus, UserMinus, Crown, Shield, User } from 'lucide-react'
import { useState } from 'react'
import { api } from '../utils/api'

const Employees = ({ business, refreshBusiness, setModal }) => {
  const [searchTerm, setSearchTerm] = useState('')

  const filteredEmployees = business?.employees?.filter(emp =>
    emp.name?.toLowerCase().includes(searchTerm.toLowerCase()) ||
    emp.citizenid?.toLowerCase().includes(searchTerm.toLowerCase())
  ) || []

  const getRoleIcon = (role) => {
    switch (role) {
      case 'owner':
        return Crown
      case 'manager':
        return Shield
      default:
        return User
    }
  }

  const getRoleColor = (role) => {
    switch (role) {
      case 'owner':
        return 'text-yellow-400'
      case 'manager':
        return 'text-blue-400'
      default:
        return 'text-slate-400'
    }
  }

  const handleHire = () => {
    setModal({
      type: 'input',
      title: 'Hire Employee',
      fields: [
        {
          name: 'citizenid',
          label: 'Citizen ID',
          type: 'text',
          placeholder: 'Enter citizen ID...',
          required: true,
        },
        {
          name: 'role',
          label: 'Role',
          type: 'select',
          options: [
            { value: 'employee', label: 'Employee' },
            { value: 'manager', label: 'Manager' },
          ],
          defaultValue: 'employee',
          required: true,
        },
      ],
      onSubmit: async (data) => {
        const result = await api.hireEmployee(business.id, data.citizenid, data.role)
        if (result.success) {
          refreshBusiness()
        }
        return result
      },
    })
  }

  const handleFire = (employee) => {
    setModal({
      type: 'confirm',
      title: 'Fire Employee',
      message: `Are you sure you want to fire ${employee.name}?`,
      onSubmit: async () => {
        const result = await api.fireEmployee(business.id, employee.citizenid)
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
        <h2 className="text-2xl font-bold text-white">Employee Management</h2>
        {business?.role === 'owner' || business?.role === 'manager' ? (
          <button
            onClick={handleHire}
            className="flex items-center gap-2 px-4 py-2 bg-primary-600 text-white rounded-lg hover:bg-primary-700 transition-colors"
          >
            <UserPlus className="w-5 h-5" />
            Hire Employee
          </button>
        ) : null}
      </div>

      {/* Search */}
      <input
        type="text"
        placeholder="Search employees..."
        value={searchTerm}
        onChange={(e) => setSearchTerm(e.target.value)}
        className="w-full px-4 py-2 bg-slate-800 border border-slate-700 rounded-lg text-white placeholder-slate-400 focus:outline-none focus:ring-2 focus:ring-primary-500"
      />

      {/* Employees List */}
      <div className="bg-slate-800 rounded-lg border border-slate-700 overflow-hidden">
        <div className="p-4 border-b border-slate-700">
          <h3 className="font-semibold text-white">
            Employees ({filteredEmployees.length})
          </h3>
        </div>
        <div className="divide-y divide-slate-700">
          {filteredEmployees.length > 0 ? (
            filteredEmployees.map((employee, index) => {
              const RoleIcon = getRoleIcon(employee.role)
              const roleColor = getRoleColor(employee.role)
              return (
                <div
                  key={index}
                  className="p-4 hover:bg-slate-700/50 transition-colors"
                >
                  <div className="flex items-center justify-between">
                    <div className="flex items-center gap-3">
                      <div className="p-2 bg-slate-700 rounded-lg">
                        <RoleIcon className={`w-5 h-5 ${roleColor}`} />
                      </div>
                      <div>
                        <p className="font-medium text-white">{employee.name}</p>
                        <p className="text-sm text-slate-400 capitalize">{employee.role}</p>
                        <p className="text-xs text-slate-500">{employee.citizenid}</p>
                      </div>
                    </div>
                    {(business?.role === 'owner' || business?.role === 'manager') &&
                      employee.role !== 'owner' && (
                        <button
                          onClick={() => handleFire(employee)}
                          className="flex items-center gap-2 px-3 py-1.5 bg-red-600 text-white rounded-lg hover:bg-red-700 transition-colors"
                        >
                          <UserMinus className="w-4 h-4" />
                          Fire
                        </button>
                      )}
                  </div>
                </div>
              )
            })
          ) : (
            <div className="p-8 text-center">
              <Users className="w-12 h-12 text-slate-500 mx-auto mb-3" />
              <p className="text-slate-400">No employees found</p>
            </div>
          )}
        </div>
      </div>
    </div>
  )
}

export default Employees

