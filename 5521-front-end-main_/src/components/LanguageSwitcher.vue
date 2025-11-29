<template>
  <div class="language-switcher">
    <select class="lang-select" v-model="currentLanguage" @change="onChange">
      <option v-for="lang in languages" :key="lang.code" :value="lang.code">{{ lang.name }}</option>
    </select>
  </div>
</template>

<script>
export default {
  name: 'LanguageSwitcher',
  props: {
    modelValue: {
      type: String,
      default: 'en',
    },
  },
  data() {
    return {
      currentLanguage: this.modelValue,
      languages: [
        { code: 'en', name: 'English' },
        { code: 'zh', name: '中文' },
      ],
    }
  },
  watch: {
    modelValue(newVal) {
      this.currentLanguage = newVal
    },
  },
  methods: {
    onChange() {
      this.$emit('update:modelValue', this.currentLanguage)
      localStorage.setItem('language', this.currentLanguage)
    },
  },
}
</script>

<style scoped>
.language-switcher {
  width: 100%;
}
.lang-select {
  width: 100%;
  padding: 8px 10px;
  border-radius: 8px;
  border: 1px solid rgba(255, 255, 255, 0.04);
  background: var(--card);
  color: var(--text);
  font-size: 13px;
}
.lang-select:focus {
  outline: none;
  box-shadow: 0 0 0 3px rgba(79, 70, 229, 0.06);
}
</style>
