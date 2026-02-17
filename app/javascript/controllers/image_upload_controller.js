import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["dropzone", "input", "preview", "previewImage", "fileName", "currentImage"]

  browse(e) {
    e.preventDefault()
    e.stopPropagation()
    this.inputTarget.click()
  }

  fileSelected(e) {
    const files = e.target.files
    this.handleFiles(files)
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

  handleFiles(files) {
    if (files.length === 0) return

    const file = files[0]

    if (!file.type.match('image.*')) {
      alert('Por favor selecciona una imagen válida (JPEG, PNG, GIF)')
      return
    }

    if (file.size > 5 * 1024 * 1024) {
      alert('La imagen es demasiado grande. El tamaño máximo es 5MB')
      return
    }

    const dataTransfer = new DataTransfer()
    dataTransfer.items.add(file)
    this.inputTarget.files = dataTransfer.files

    this.showPreview(file)
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
