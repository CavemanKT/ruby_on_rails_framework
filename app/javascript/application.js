// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import "flowbite"

// 初始化 Flowbite 组件
// 确保在 Turbo 导航后重新初始化 Flowbite
document.addEventListener("turbo:load", () => {
  if (typeof initFlowbite === 'function') {
    initFlowbite();
  }
});

document.addEventListener("turbo:render", () => {
  if (typeof initFlowbite === 'function') {
    initFlowbite();
  }
});