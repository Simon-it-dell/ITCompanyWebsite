document.addEventListener('DOMContentLoaded', function () {
  const navLinks = document.querySelectorAll('.nav-links a');
  navLinks.forEach((link) => {
    link.addEventListener('click', function (event) {
      event.preventDefault();
      const targetId = this.getAttribute('href').substring(1);
      const targetElement = document.getElementById(targetId);
      if (targetElement) {
        targetElement.scrollIntoView({ behavior: 'smooth' });
      }
      // close mobile nav if open
      const topbar = document.querySelector('.topbar');
      if (topbar && topbar.classList.contains('open')) {
        topbar.classList.remove('open');
      }
    });
  });

  const navToggle = document.querySelector('.nav-toggle');
  const topbar = document.querySelector('.topbar');
  if (navToggle && topbar) {
    navToggle.addEventListener('click', () => {
      topbar.classList.toggle('open');
    });
  }

  // Contact form submission (AJAX)
  const contactForm = document.getElementById('contact-form');
  const formStatus = document.getElementById('form-status');
  if (contactForm) {
    contactForm.addEventListener('submit', async function (e) {
      e.preventDefault();
      if (formStatus) formStatus.textContent = 'Sending...';
      const action = contactForm.action;
      const formData = new FormData(contactForm);
      try {
        const res = await fetch(action, {
          method: 'POST',
          body: formData,
          headers: { 'Accept': 'application/json' }
        });
        if (res.ok) {
          contactForm.reset();
          if (formStatus) {
            formStatus.textContent = '';
            formStatus.classList.remove('error');
            formStatus.classList.add('success');
          }
          // Replace the form with a friendly inline thank-you message
          contactForm.classList.add('submitted');
          contactForm.innerHTML = `
            <div class="thankyou">
              <h3>Thanks — message sent!</h3>
              <p>We'll reply to your email shortly. In the meantime you can return to the homepage.</p>
              <a class="btn btn-secondary" href="#home">Return home</a>
            </div>
          `;
          // Auto-scroll/return home after a short delay
          setTimeout(() => { window.location.hash = '#home'; }, 4000);
        } else {
          const data = await res.json();
          if (formStatus) formStatus.textContent = data.error || 'There was a problem sending the message.';
          if (formStatus) formStatus.classList.add('error');
        }
      } catch (err) {
        console.error(err);
        if (formStatus) {
          formStatus.innerHTML = 'Network error. Please try again later or email <a href="mailto:simonrata160@gmail.com">simonrata160@gmail.com</a>';
          formStatus.classList.add('error');
        }
      }
    });
  }
});
