// Like button controller
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button"]
  static values = { postId: Number }
  
  async like(event) {
    event.preventDefault()
    
    try {
      const response = await fetch(`/posts/${this.postIdValue}/like`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
        }
      })
      
      if (response.ok) {
        const data = await response.json()
        this.updateButton(data.liked, data.likes_count)
      } else {
        const errorData = await response.json()
        console.error('Error liking post:', errorData.error)
      }
    } catch (error) {
      console.error('Error liking post:', error)
    }
  }
  
  updateButton(liked, likesCount) {
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
    
    // 更新点赞计数显示（如果页面中有显示的话）
    const likesCountElement = document.querySelector(`[data-post-id="${this.postIdValue}"] .likes-count`)
    if (likesCountElement && likesCount !== undefined) {
      const countText = likesCount === 1 ? '1 like' : `${likesCount} likes`
      likesCountElement.textContent = countText
      
      // 如果点赞数为0，隐藏计数显示
      if (likesCount === 0) {
        likesCountElement.style.display = 'none'
      } else {
        likesCountElement.style.display = 'flex'
      }
    }
  }
}
