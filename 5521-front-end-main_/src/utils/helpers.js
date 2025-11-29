/**
 * 辅助函数库
 */

// 在调试信息中添加日志
export function addDebugInfo(message, debugInfoRef) {
  if (debugInfoRef) {
    const timestamp = new Date().toLocaleTimeString()
    debugInfoRef.innerHTML += `[${timestamp}] ${message}<br>`
    debugInfoRef.scrollTop = debugInfoRef.scrollHeight
  }
}

// 清空调试信息
export function clearDebug(debugInfoRef) {
  if (debugInfoRef) {
    debugInfoRef.innerHTML = ''
  }
}

// 导出调试信息
export function exportDebugInfo(debugInfoRef) {
  if (!debugInfoRef) return

  const debugInfo = debugInfoRef.innerText
  const blob = new Blob([debugInfo], { type: 'text/plain' })
  const url = URL.createObjectURL(blob)
  const a = document.createElement('a')
  a.href = url
  a.download = 'debug_info.txt'
  a.click()
  URL.revokeObjectURL(url)
}

// 显示状态消息
export function showStatus(elementRef, message, type, debugInfoRef) {
  if (elementRef) {
    elementRef.innerHTML = message
    elementRef.className = 'status ' + type
  }
  addDebugInfo(`Status: ${message}`, debugInfoRef)
}

// 验证以太坊地址
export function isValidAddress(address) {
  return /^0x[a-fA-F0-9]{40}$/.test(address)
}

// 根据链ID获取网络名称
export function getNetworkName(chainId) {
  const networks = {
    '0x1': '以太坊主网',
    '0xaa36a7': 'Sepolia测试网',
    '0x5': 'Goerli测试网',
    '0x539': '本地开发网络',
  }
  return networks[chainId] || `未知网络 (${chainId})`
}

// 格式化时间秒数
export function formatTimeRemaining(seconds) {
  const minutes = Math.floor(seconds / 60)
  const secs = seconds % 60
  return `${minutes} 分钟 ${secs} 秒`
}
