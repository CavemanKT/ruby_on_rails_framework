// Modal controller for handling modal dialogs
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal"]
  
  connect() {
    // 当模态框连接时，显示它
    this.show()
  }
  
  show() {
    if (this.hasModalTarget) {
      this.modalTarget.classList.remove('hidden')
      document.body.style.overflow = 'hidden' // 防止背景滚动
    }
  }
  
  close() {
    if (this.hasModalTarget) {
      this.modalTarget.classList.add('hidden')
      document.body.style.overflow = '' // 恢复滚动
    }
  }
  
  // 点击背景关闭模态框
  backdropClick(event) {
    if (event.target === event.currentTarget) {
      this.close()
    }
  }
  
  // ESC 键关闭模态框
  keydown(event) {
    if (event.key === 'Escape') {
      this.close()
    }
  }
}
