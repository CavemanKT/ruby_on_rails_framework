// Character count controller for text areas
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "counter"]
  
  connect() {
    this.update()
  }
  
  update() {
    if (this.hasCounterTarget && this.hasInputTarget) {
      const length = this.inputTarget.value.length
      const maxLength = this.inputTarget.getAttribute('maxlength') || 5000
      
      this.counterTarget.textContent = `${length} / ${maxLength}`
      
      // 当接近限制时改变颜色
      if (length > maxLength * 0.9) {
        this.counterTarget.classList.add('text-red-500')
        this.counterTarget.classList.remove('text-gray-500')
      } else {
        this.counterTarget.classList.remove('text-red-500')
        this.counterTarget.classList.add('text-gray-500')
      }
    }
  }
}
