import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["dropzone", "input", "preview", "previewImage", "fileName", "removeButton"]

  connect() {
    this.setupDragAndDrop()
  }

  setupDragAndDrop() {
    const dropzone = this.dropzoneTarget

    // Prevent default drag behaviors
    ['dragenter', 'dragover', 'dragleave', 'drop'].forEach(eventName => {
      dropzone.addEventListener(eventName, this.preventDefaults.bind(this), false)
      document.body.addEventListener(eventName, this.preventDefaults.bind(this), false)
    })

    // Highlight drop zone when item is dragged over it
    ['dragenter', 'dragover'].forEach(eventName => {
      dropzone.addEventListener(eventName, this.highlight.bind(this), false)
    })

    ['dragleave', 'drop'].forEach(eventName => {
      dropzone.addEventListener(eventName, this.unhighlight.bind(this), false)
    })

    // Handle dropped files
    dropzone.addEventListener('drop', this.handleDrop.bind(this), false)
  }

  preventDefaults(e) {
    e.preventDefault()
    e.stopPropagation()
  }

  highlight(e) {
    this.dropzoneTarget.classList.add('border-blue-500', 'bg-blue-50')
  }

  unhighlight(e) {
    this.dropzoneTarget.classList.remove('border-blue-500', 'bg-blue-50')
  }

  handleDrop(e) {
    const dt = e.dataTransfer
    const files = dt.files

    this.handleFiles(files)
  }

  // Triggered when user clicks to browse files
  browse(e) {
    e.preventDefault()
    this.inputTarget.click()
  }

  // Triggered when user selects files via input
  fileSelected(e) {
    const files = e.target.files
    this.handleFiles(files)
  }

  handleFiles(files) {
    if (files.length === 0) return

    const file = files[0]

    // Validate file type
    if (!file.type.match('image.*')) {
      alert('Por favor selecciona una imagen válida (JPEG, PNG, GIF)')
      return
    }

    // Validate file size (5MB max)
    if (file.size > 5 * 1024 * 1024) {
      alert('La imagen es demasiado grande. El tamaño máximo es 5MB')
      return
    }

    // Update the file input
    const dataTransfer = new DataTransfer()
    dataTransfer.items.add(file)
    this.inputTarget.files = dataTransfer.files

    // Show preview
    this.showPreview(file)
  }

  showPreview(file) {
    const reader = new FileReader()

    reader.onload = (e) => {
      this.previewImageTarget.src = e.target.result
      this.fileNameTarget.textContent = file.name
      this.previewTarget.classList.remove('hidden')
      this.dropzoneTarget.classList.add('hidden')
    }

    reader.readAsDataURL(file)
  }

  removeImage(e) {
    e.preventDefault()

    // Clear the file input
    this.inputTarget.value = ''

    // Hide preview and show dropzone
    this.previewTarget.classList.add('hidden')
    this.dropzoneTarget.classList.remove('hidden')

    // Reset preview image
    this.previewImageTarget.src = ''
    this.fileNameTarget.textContent = ''
  }
}
