// Breathing exercise controller
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["circle", "phaseLabel", "countdown", "timer", "cycle", "playButton", "pauseButton", "stopButton", "completionMessage", "progress", "progressRing", "loadingOverlay"]
  static values = { sessionId: String, phases: Object }
  
  connect() {
    this.isRunning = false
    this.isPaused = false
    this.currentTime = 0
    this.interval = null
    this.currentPhase = 'inhale'
    this.phaseTime = 0
    this.currentCycle = 1
    this.totalCycles = 5
    
    // 初始化动画
    this.updateDisplay()
    this.initializePhases()
  }
  
  initializePhases() {
    // 确保 phases 数据正确传递
    if (!this.phasesValue || Object.keys(this.phasesValue).length === 0) {
      this.phasesValue = {
        inhale: { duration: 4, label: "Breathe In", color: "blue" },
        hold: { duration: 4, label: "Hold", color: "green" },
        exhale: { duration: 6, label: "Breathe Out", color: "purple" }
      }
    }
  }
  
  disconnect() {
    this.stop()
  }
  
  toggle() {
    if (this.isRunning) {
      this.pause()
    } else {
      this.start()
    }
  }
  
  start() {
    this.isRunning = true
    this.isPaused = false
    this.playButtonTarget.textContent = 'Pause'
    this.playButtonTarget.classList.add('hidden')
    this.pauseButtonTarget.classList.remove('hidden')
    
    this.interval = setInterval(() => {
      this.tick()
    }, 1000)
  }
  
  pause() {
    this.isRunning = false
    this.isPaused = true
    this.playButtonTarget.textContent = 'Resume'
    this.playButtonTarget.classList.remove('hidden')
    this.pauseButtonTarget.classList.add('hidden')
    
    clearInterval(this.interval)
  }
  
  stop() {
    this.isRunning = false
    this.isPaused = false
    clearInterval(this.interval)
    
    // 重置到初始状态
    this.currentTime = 0
    this.currentCycle = 1
    this.currentPhase = 'inhale'
    this.phaseTime = 0
    
    this.updateDisplay()
    this.playButtonTarget.textContent = 'Start Exercise'
    this.playButtonTarget.classList.remove('hidden')
    this.pauseButtonTarget.classList.add('hidden')
  }
  
  tick() {
    this.currentTime++
    this.phaseTime++
    
    const phaseData = this.phasesValue[this.currentPhase]
    const phaseDuration = phaseData.duration
    
    // 检查是否需要切换到下一个阶段
    if (this.phaseTime >= phaseDuration) {
      this.nextPhase()
    }
    
    this.updateDisplay()
    
    // 检查是否完成所有周期
    if (this.currentCycle > this.totalCycles) {
      this.complete()
    }
  }
  
  nextPhase() {
    this.phaseTime = 0
    
    // 切换到下一个阶段
    switch (this.currentPhase) {
      case 'inhale':
        this.currentPhase = 'hold'
        break
      case 'hold':
        this.currentPhase = 'exhale'
        break
      case 'exhale':
        this.currentPhase = 'inhale'
        this.currentCycle++
        break
    }
  }
  
  updateDisplay() {
    // 更新阶段标签和倒计时
    const phaseData = this.phasesValue[this.currentPhase]
    const timeLeft = phaseData.duration - this.phaseTime
    
    this.phaseLabelTarget.textContent = phaseData.label
    this.countdownTarget.textContent = timeLeft
    
    // 更新周期和总时间
    this.cycleTarget.textContent = this.currentCycle
    this.timerTarget.textContent = this.formatTime(this.currentTime)
    
    // 更新动画圆圈
    this.updateCircleAnimation()
    
    // 更新进度环
    this.updateProgressRing()
  }
  
  updateCircleAnimation() {
    const phaseData = this.phasesValue[this.currentPhase]
    const progress = this.phaseTime / phaseData.duration
    
    // 根据阶段改变圆圈大小和颜色
    let scale = 1
    switch (this.currentPhase) {
      case 'inhale':
        scale = 1 + (progress * 0.5) // 吸气时放大
        this.circleTarget.style.borderColor = 'rgba(59, 130, 246, 0.8)' // blue
        break
      case 'hold':
        scale = 1.5 // 保持最大
        this.circleTarget.style.borderColor = 'rgba(34, 197, 94, 0.8)' // green
        break
      case 'exhale':
        scale = 1.5 - (progress * 0.5) // 呼气时缩小
        this.circleTarget.style.borderColor = 'rgba(147, 51, 234, 0.8)' // purple
        break
    }
    
    this.circleTarget.style.transform = `scale(${scale})`
    this.circleTarget.style.transition = 'transform 0.1s ease-in-out'
  }
  
  updateProgressRing() {
    const totalDuration = this.totalCycles * 14 // 5 cycles * (4+4+6) seconds
    const progress = Math.min(this.currentTime / totalDuration, 1)
    const circumference = 754 // 2 * PI * 120
    const offset = circumference - (progress * circumference)
    
    this.progressTarget.style.strokeDashoffset = offset
  }
  
  formatTime(seconds) {
    const mins = Math.floor(seconds / 60)
    const secs = seconds % 60
    return `${mins}:${secs.toString().padStart(2, '0')}`
  }
  
  complete() {
    this.stop()
    this.completionMessageTarget.classList.remove('hidden')
    
    // 保存练习完成状态
    this.finish()
  }
  
  async finish() {
    this.showLoading()
    
    try {
      const response = await fetch(`/breathing_exercises/${this.sessionIdValue}/finish`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
        },
        body: JSON.stringify({
          duration: this.currentTime
        })
      })
      
      if (response.ok) {
        const data = await response.json()
        console.log('Exercise completed successfully:', data)
        // 显示积分获得提示
        this.showPointsEarned(data.calm_points)
        // 延迟跳转到完成页面
        setTimeout(() => {
          window.location.href = `/breathing_exercises/${this.sessionIdValue}/completed`
        }, 2000)
      } else {
        throw new Error('Failed to save exercise')
      }
    } catch (error) {
      console.error('Error finishing exercise:', error)
      this.hideLoading()
      alert('Failed to save your exercise. Please try again.')
    }
  }
  
  showPointsEarned(points) {
    // 创建积分获得提示
    const notification = document.createElement('div')
    notification.className = 'fixed top-4 right-4 bg-yellow-100 border border-yellow-400 text-yellow-800 px-4 py-3 rounded-lg shadow-lg z-50'
    notification.innerHTML = `
      <div class="flex items-center">
        <svg class="h-5 w-5 text-yellow-600 mr-2" fill="currentColor" viewBox="0 0 20 20">
          <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z"></path>
        </svg>
        <span class="font-semibold">+${points} Calm Points earned!</span>
      </div>
    `
    
    document.body.appendChild(notification)
    
    // 3秒后自动移除
    setTimeout(() => {
      notification.remove()
    }, 3000)
  }
  
  showLoading() {
    this.loadingOverlayTarget.classList.remove('hidden')
  }
  
  hideLoading() {
    this.loadingOverlayTarget.classList.add('hidden')
  }
}
