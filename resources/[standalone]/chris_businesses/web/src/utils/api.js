// NUI API utility for FiveM callbacks

const resourceName = (() => {
  try {
    return window.GetParentResourceName ? window.GetParentResourceName() : 'chris_businesses'
  } catch (e) {
    return 'chris_businesses'
  }
})()

export const nuiCallback = (eventName, data = {}) => {
  return new Promise((resolve) => {
    fetch(`https://${resourceName}/${eventName}`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(data)
    }).then(res => res.json()).then(resolve).catch(err => {
      console.error('NUI Callback Error:', err)
      resolve({ success: false, error: err.message })
    })
  })
}


// API functions
export const api = {
  getBusiness: (businessId) => nuiCallback('getBusiness', { businessId }),
  purchaseBusiness: (businessId) => nuiCallback('purchaseBusiness', { businessId }),
  sellBusiness: (businessId, price) => nuiCallback('sellBusiness', { businessId, price }),
  hireEmployee: (businessId, citizenid, role) => nuiCallback('hireEmployee', { businessId, citizenid, role }),
  fireEmployee: (businessId, citizenid) => nuiCallback('fireEmployee', { businessId, citizenid }),
  updateSettings: (businessId, settings) => nuiCallback('updateSettings', { businessId, settings }),
  depositMoney: (businessId, amount) => nuiCallback('depositMoney', { businessId, amount }),
  withdrawMoney: (businessId, amount) => nuiCallback('withdrawMoney', { businessId, amount }),
}

// Close NUI
export const closeNUI = () => {
  fetch(`https://${resourceName}/closeDashboard`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({})
  })
}

