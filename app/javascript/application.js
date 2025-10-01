// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import "flowbite"

// 全局组件管理器
const GlobalComponentManager = {
  // 初始化所有组件
  init: function() {
    this.initPasswordToggles()
    this.initThemeToggle()
    this.initFlowbiteComponents()
  },

  // 密码切换功能
  initPasswordToggles: function() {
    const toggles = document.querySelectorAll('[data-password-toggle]')
    
    toggles.forEach(toggle => {
      const inputId = toggle.getAttribute('data-password-toggle')
      const input = document.getElementById(inputId)
      
      if (!input) return
      
      // 移除旧的事件监听器
      toggle.removeEventListener('click', toggle._passwordToggleHandler)
      
      // 创建新的事件处理器
      toggle._passwordToggleHandler = function(e) {
        e.preventDefault()
        e.stopPropagation()
        
        const isPassword = input.getAttribute('type') === 'password'
        input.setAttribute('type', isPassword ? 'text' : 'password')
        
        // 切换图标
        const eyeIcon = toggle.querySelector('[data-eye-icon]')
        const eyeSlashIcon = toggle.querySelector('[data-eye-slash-icon]')
        
        if (eyeIcon && eyeSlashIcon) {
          if (isPassword) {
            eyeIcon.classList.add('hidden')
            eyeSlashIcon.classList.remove('hidden')
          } else {
            eyeIcon.classList.remove('hidden')
            eyeSlashIcon.classList.add('hidden')
          }
        }
      }
      
      // 绑定事件
      toggle.addEventListener('click', toggle._passwordToggleHandler)
    })
  },

  // 深色模式切换
  initThemeToggle: function() {
    const themeToggle = document.getElementById('theme-toggle')
    if (!themeToggle) return

    // 移除旧的事件监听器
    themeToggle.removeEventListener('click', themeToggle._themeToggleHandler)

    // 创建新的事件处理器
    themeToggle._themeToggleHandler = function() {
      const lightIcon = document.getElementById('theme-toggle-light-icon')
      const darkIcon = document.getElementById('theme-toggle-dark-icon')
      
      if (!lightIcon || !darkIcon) return
      
      // 切换图标
      lightIcon.classList.toggle('hidden')
      darkIcon.classList.toggle('hidden')
      
      // 切换主题
      const htmlElement = document.documentElement
      const currentTheme = localStorage.getItem('color-theme')
      
      if (currentTheme === 'dark') {
        htmlElement.classList.remove('dark')
        localStorage.setItem('color-theme', 'light')
      } else if (currentTheme === 'light') {
        htmlElement.classList.add('dark')
        localStorage.setItem('color-theme', 'dark')
      } else {
        // 首次设置
        if (htmlElement.classList.contains('dark')) {
          htmlElement.classList.remove('dark')
          localStorage.setItem('color-theme', 'light')
        } else {
          htmlElement.classList.add('dark')
          localStorage.setItem('color-theme', 'dark')
        }
      }
    }

    // 绑定事件
    themeToggle.addEventListener('click', themeToggle._themeToggleHandler)

    // 更新图标状态
    this.updateThemeIcon()
  },

  // 更新深色模式图标
  updateThemeIcon: function() {
    const lightIcon = document.getElementById('theme-toggle-light-icon')
    const darkIcon = document.getElementById('theme-toggle-dark-icon')
    
    if (!lightIcon || !darkIcon) return
    
    const isDark = localStorage.getItem('color-theme') === 'dark' || 
                  (!localStorage.getItem('color-theme') && 
                   window.matchMedia('(prefers-color-scheme: dark)').matches)
    
    if (isDark) {
      lightIcon.classList.remove('hidden')
      darkIcon.classList.add('hidden')
    } else {
      darkIcon.classList.remove('hidden')
      lightIcon.classList.add('hidden')
    }
  },

  // Flowbite 组件初始化
  initFlowbiteComponents: function() {
    if (typeof initFlowbite === 'function') {
      initFlowbite()
    }
  }
}

// 页面加载时初始化
document.addEventListener('DOMContentLoaded', function() {
  GlobalComponentManager.init()
})

// Turbo 事件处理
document.addEventListener('turbo:load', function() {
  GlobalComponentManager.init()
})

document.addEventListener('turbo:render', function() {
  GlobalComponentManager.init()
})

document.addEventListener('turbo:frame-load', function() {
  GlobalComponentManager.init()
})

// 立即执行（防止时机问题）
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', function() {
    GlobalComponentManager.init()
  })
} else {
  GlobalComponentManager.init()
}