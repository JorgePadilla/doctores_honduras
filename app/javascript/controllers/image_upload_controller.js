import { Controller } from "@hotwired/stimulus"

// Max longest edge the browser downscales to before upload. The server makes the
// final 1000px/400px WebP variants, so this just keeps uploads small and fast.
const MAX_EDGE = 1600
const QUALITY = 0.85

export default class extends Controller {
  static targets = ["dropzone", "input", "preview", "previewImage", "fileName", "currentImage"]

  browse(e) {
    e.preventDefault()
    e.stopPropagation()
    this.inputTarget.click()
  }

  fileSelected(e) {
    this.handleFiles(e.target.files)
  }

  highlight(e) {
    e.preventDefault()
    e.stopPropagation()
    this.dropzoneTarget.classList.add('border-sky-500', 'bg-sky-50', 'dark:bg-sky-900/10')
  }

  unhighlight(e) {
    e.preventDefault()
    e.stopPropagation()
    this.dropzoneTarget.classList.remove('border-sky-500', 'bg-sky-50', 'dark:bg-sky-900/10')
  }

  handleDrop(e) {
    e.preventDefault()
    e.stopPropagation()
    this.unhighlight(e)
    this.handleFiles(e.dataTransfer.files)
  }

  async handleFiles(files) {
    if (files.length === 0) return

    let file = files[0]

    if (!file.type.match('image.*')) {
      alert('Por favor selecciona una imagen válida (JPEG, PNG, GIF o WebP)')
      return
    }

    if (file.size > 5 * 1024 * 1024) {
      alert('La imagen es demasiado grande. El tamaño máximo es 5MB')
      return
    }

    // Instant preview from the original while we optimize in the background.
    this.showPreview(file)

    try {
      const optimized = await this.resizeAndConvert(file)
      if (optimized) file = optimized
    } catch (err) {
      console.warn('[image-upload] client optimization failed, uploading original', err)
    }

    const dataTransfer = new DataTransfer()
    dataTransfer.items.add(file)
    this.inputTarget.files = dataTransfer.files
    this.fileNameTarget.textContent = file.name
  }

  // Downscale + re-encode to WebP (or JPEG fallback) using a canvas.
  // Returns a new File, or null to keep the original.
  async resizeAndConvert(file) {
    if (file.type === 'image/svg+xml') return null

    const img = await this.loadImage(file)
    const scale = Math.min(1, MAX_EDGE / Math.max(img.width, img.height))
    const width = Math.round(img.width * scale)
    const height = Math.round(img.height * scale)

    const canvas = document.createElement('canvas')
    canvas.width = width
    canvas.height = height
    canvas.getContext('2d').drawImage(img, 0, 0, width, height)
    URL.revokeObjectURL(img.src)

    const supportsWebp = canvas.toDataURL('image/webp').startsWith('data:image/webp')
    const type = supportsWebp ? 'image/webp' : 'image/jpeg'
    const ext = supportsWebp ? 'webp' : 'jpg'

    const blob = await new Promise((resolve) => canvas.toBlob(resolve, type, QUALITY))
    if (!blob) return null

    // Skip if conversion didn't actually help (e.g. already-small WebP).
    if (scale === 1 && blob.size >= file.size) return null

    const baseName = file.name.replace(/\.[^.]+$/, '') || 'image'
    return new File([blob], `${baseName}.${ext}`, { type })
  }

  loadImage(file) {
    return new Promise((resolve, reject) => {
      const img = new Image()
      img.onload = () => resolve(img)
      img.onerror = reject
      img.src = URL.createObjectURL(file)
    })
  }

  showPreview(file) {
    const reader = new FileReader()

    reader.onload = (e) => {
      this.previewImageTarget.src = e.target.result
      this.fileNameTarget.textContent = file.name
      this.previewTarget.classList.remove('hidden')
      this.dropzoneTarget.classList.add('hidden')
      if (this.hasCurrentImageTarget) {
        this.currentImageTarget.classList.add('hidden')
      }
    }

    reader.readAsDataURL(file)
  }

  removeImage(e) {
    e.preventDefault()
    this.inputTarget.value = ''
    this.previewTarget.classList.add('hidden')
    this.previewImageTarget.src = ''
    this.fileNameTarget.textContent = ''

    if (this.hasCurrentImageTarget) {
      this.currentImageTarget.classList.remove('hidden')
      this.dropzoneTarget.classList.add('hidden')
    } else {
      this.dropzoneTarget.classList.remove('hidden')
    }
  }

  showReplace(e) {
    e.preventDefault()
    if (this.hasCurrentImageTarget) {
      this.currentImageTarget.classList.add('hidden')
    }
    this.dropzoneTarget.classList.remove('hidden')
  }

  cancelReplace(e) {
    e.preventDefault()
    e.stopPropagation()
    this.dropzoneTarget.classList.add('hidden')
    if (this.hasCurrentImageTarget) {
      this.currentImageTarget.classList.remove('hidden')
    }
  }
}
