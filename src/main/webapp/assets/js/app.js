/**
 * Online Shopping Cart - Frontend Enhancements & Utilities
 */

document.addEventListener('DOMContentLoaded', () => {
    // 1. Initialize Bootstrap tooltips if available
    const tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'));
    tooltipTriggerList.forEach(tooltipTriggerEl => {
        if (window.bootstrap && window.bootstrap.Tooltip) {
            new window.bootstrap.Tooltip(tooltipTriggerEl);
        }
    });

    // 2. Destructive action confirmations
    document.querySelectorAll('[data-confirm]').forEach(btn => {
        btn.addEventListener('click', (e) => {
            const message = btn.getAttribute('data-confirm') || 'Are you sure you want to proceed?';
            if (!confirm(message)) {
                e.preventDefault();
            }
        });
    });

    // 3. Admin product image preview
    const imageInput = document.getElementById('imageFileInput');
    const imagePreview = document.getElementById('imagePreviewTarget');
    if (imageInput && imagePreview) {
        imageInput.addEventListener('change', () => {
            const file = imageInput.files[0];
            if (file) {
                const reader = new FileReader();
                reader.onload = (e) => {
                    imagePreview.src = e.target.result;
                    imagePreview.classList.remove('d-none');
                };
                reader.readAsDataURL(file);
            }
        });
    }

    // 4. Auto-dismiss success alert banners after 5 seconds
    const autoAlerts = document.querySelectorAll('.alert-dismissible');
    autoAlerts.forEach(alert => {
        setTimeout(() => {
            if (window.bootstrap && window.bootstrap.Alert) {
                const bsAlert = new window.bootstrap.Alert(alert);
                bsAlert.close();
            }
        }, 6000);
    });
});
