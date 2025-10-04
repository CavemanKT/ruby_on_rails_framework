// Like button controller
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button"]
  
  connect() {
    this.postId = this.data.get("postId")
  }
  
  async like(event) {
    event.preventDefault()
    
    try {
      const response = await fetch(`/posts/${this.postId}/like`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
        }
      })
      
      if (response.ok) {
        const data = await response.json()
        this.updateButton(data.liked)
      }
    } catch (error) {
      console.error('Error liking post:', error)
    }
  }
  
  updateButton(liked) {
    const icon = this.buttonTarget.querySelector('svg')
    const text = this.buttonTarget.querySelector('span')
    
    if (liked) {
      // 已点赞状态
      icon.classList.remove('text-gray-400')
      icon.classList.add('text-red-500')
      icon.querySelector('path').setAttribute('fill', 'currentColor')
      text.textContent = 'Liked'
    } else {
      // 未点赞状态
      icon.classList.remove('text-red-500')
      icon.classList.add('text-gray-400')
      icon.querySelector('path').removeAttribute('fill')
      text.textContent = 'Like'
    }
  }
}
