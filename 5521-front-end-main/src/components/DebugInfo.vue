<template>
  <div class="card">
    <h2>DebugInfo</h2>
    <div class="marketplace-actions">
      <button @click="clearDebug">Clear Debug Info</button>
      <button @click="exportDebugInfo">Export Debug Info</button>
    </div>
    <div ref="debugInfo" class="debug-info"></div>
  </div>
</template>

<script>
import { clearDebug, exportDebugInfo as exportDebug } from '../utils/helpers'

export default {
  name: 'DebugInfo',
  methods: {
    addDebugInfo(message) {
      const timestamp = new Date().toLocaleTimeString()
      this.$refs.debugInfo.innerHTML += `[${timestamp}] ${message}<br>`
      this.$refs.debugInfo.scrollTop = this.$refs.debugInfo.scrollHeight
    },
    clearDebug() {
      this.$refs.debugInfo.innerHTML = ''
    },
    exportDebugInfo() {
      const debugInfo = this.$refs.debugInfo.innerText
      const blob = new Blob([debugInfo], { type: 'text/plain' })
      const url = URL.createObjectURL(blob)
      const a = document.createElement('a')
      a.href = url
      a.download = 'debug_info.txt'
      a.click()
      URL.revokeObjectURL(url)
    },
  },
}
</script>

<style scoped></style>
