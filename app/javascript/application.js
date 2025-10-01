// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import "flowbite"

// 全局密码切换功能
function setupPasswordToggles() {
  // 查找所有密码切换按钮
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
}

// 初始化 Flowbite 组件
function initFlowbiteComponents() {
  if (typeof initFlowbite === 'function') {
    initFlowbite()
  }
}

// 全局初始化函数
function initializeAllComponents() {
  setupPasswordToggles()
  initFlowbiteComponents()
}

// 页面加载时初始化
document.addEventListener('DOMContentLoaded', initializeAllComponents)

// Turbo 事件处理
document.addEventListener('turbo:load', initializeAllComponents)
document.addEventListener('turbo:render', initializeAllComponents)
document.addEventListener('turbo:frame-load', initializeAllComponents)

// 立即执行（防止时机问题）
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', initializeAllComponents)
} else {
  initializeAllComponents()
}