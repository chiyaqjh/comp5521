<template>
  <div class="theme-switcher">
    <label class="toggle-switch">
      <input type="checkbox" :checked="currentTheme === 'dark'" @change="toggleTheme" />
      <span class="toggle-slider">
        <span class="toggle-icon light">☀️</span>
        <span class="toggle-icon dark">🌙</span>
      </span>
    </label>
  </div>
</template>

<script>
export default {
  name: 'ThemeSwitcher',
  props: {
    modelValue: {
      type: String,
      default: 'dark',
    },
  },
  data() {
    return {
      currentTheme: this.modelValue,
    }
  },
  watch: {
    modelValue(newVal) {
      this.currentTheme = newVal
    },
  },
  methods: {
    toggleTheme() {
      const newTheme = this.currentTheme === 'dark' ? 'light' : 'dark'
      this.currentTheme = newTheme
      this.$emit('update:modelValue', newTheme)
      localStorage.setItem('theme', newTheme)
      document.documentElement.setAttribute('data-theme', newTheme)
    },
  },
  mounted() {
    const savedTheme = localStorage.getItem('theme') || 'dark'
    this.currentTheme = savedTheme
    document.documentElement.setAttribute('data-theme', savedTheme)
  },
}
</script>

<style scoped>
.theme-switcher {
  display: flex;
  align-items: center;
}

.toggle-switch {
  position: relative;
  display: inline-block;
  width: 50px;
  height: 28px;
  cursor: pointer;
}

.toggle-switch input {
  opacity: 0;
  width: 0;
  height: 0;
}

.toggle-slider {
  position: absolute;
  cursor: pointer;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background-color: var(--border);
  border-radius: 14px;
  border: 1px solid var(--border);
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  padding: 0 4px;
}

.toggle-icon {
  width: 20px;
  height: 20px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 12px;
  position: absolute;
  transition: all 0.3s ease;
}

.toggle-icon.light {
  left: 4px;
  opacity: 0.4;
}

.toggle-icon.dark {
  right: 4px;
  opacity: 1;
}

input:checked ~ .toggle-slider {
  background-color: var(--accent);
  border-color: var(--accent);
}

input:checked ~ .toggle-slider .toggle-icon.light {
  opacity: 1;
  left: 26px;
}

input:checked ~ .toggle-slider .toggle-icon.dark {
  opacity: 0.4;
  right: 26px;
}

.toggle-slider:hover {
  box-shadow: 0 0 8px rgba(0, 0, 0, 0.1);
}

[data-theme='light'] .toggle-slider:hover {
  box-shadow: 0 0 8px rgba(16, 185, 129, 0.15);
}
</style>
