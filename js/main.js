// Shared build-status logic (used by inshop.html, admin-dashboard.html)

// Build pipeline stages - single source of truth so the stage list and
// progress math can't drift between pages. Adaptive: standard builds skip
// the ATF steps, NFA builds (SBR/SBS/suppressor/machine gun) include them.
// 'in-progress' from the old 7-stage list is gone - Weld/Machining/Blasting/
// Refinishing replaced that one vague bucket with actual granular progress.
const BUILD_STAGES_STD = ['intake', 'queued', 'parts-ordered', 'weld', 'machining', 'blasting', 'refinishing', 'testing', 'ready'];
const BUILD_STAGES_NFA = ['intake', 'queued', 'parts-ordered', 'weld', 'machining', 'blasting', 'refinishing', 'testing', 'atf-filed', 'atf-approved', 'ready'];

const STATUS_LABELS = {
  'intake': 'Intake',
  'queued': 'Queued',
  'parts-ordered': 'Parts Ordered',
  'weld': 'Weld',
  'machining': 'Machining',
  'blasting': 'Blasting',
  'refinishing': 'Refinishing',
  'testing': 'Testing',
  'atf-filed': 'ATF Filed',
  'atf-approved': 'ATF Approved',
  'ready': 'Ready'
};

const STATUS_DESCRIPTIONS = {
  'intake': 'In, being assessed',
  'queued': 'Waiting on shop time, nothing started yet',
  'parts-ordered': 'Waiting on parts',
  'weld': 'On the bench, welding',
  'machining': 'On the mill or lathe',
  'blasting': 'In the blast cabinet',
  'refinishing': 'Getting coated and finished',
  'testing': 'On the range',
  'atf-filed': 'Waiting on ATF',
  'atf-approved': 'ATF cleared',
  'ready': 'Ready to transfer'
};

function calcProgress(status, isNfa) {
  const stages = isNfa ? BUILD_STAGES_NFA : BUILD_STAGES_STD;
  const si = stages.indexOf(status);
  return si === -1 ? 0 : Math.round(((si + 1) / stages.length) * 100);
}

// Escapes untrusted strings before they get dropped into innerHTML - needed
// once admin-typed and customer-typed values (build notes, intake fields,
// messages) are rendered instead of hand-coded HTML.
function escapeHtml(str) {
  return String(str ?? '').replace(/[&<>"']/g, c => ({
    '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;'
  }[c]));
}

// Mobile nav toggle
const nav = document.querySelector('.nav');
const hamburger = document.querySelector('.hamburger');
if (hamburger) {
  hamburger.addEventListener('click', () => nav.classList.toggle('nav-mobile-open'));
}

// Mark active nav link + close mobile menu on tap
const links = document.querySelectorAll('.nav-links a');
links.forEach(link => {
  if (link.href === location.href) link.classList.add('active');
  link.addEventListener('click', () => nav.classList.remove('nav-mobile-open'));
});

// Lightbox
const lightbox = document.getElementById('lightbox');
if (lightbox) {
  const lbImg = lightbox.querySelector('.lb-img');
  const lbTitle = lightbox.querySelector('.lb-title');
  const lbSub = lightbox.querySelector('.lb-sub');

  document.querySelectorAll('.gallery-item[data-title]').forEach(item => {
    item.addEventListener('click', () => {
      const src = item.dataset.src;
      const title = item.dataset.title;
      const sub = item.dataset.sub;

      if (src) {
        lbImg.src = src;
        lbImg.style.display = '';
      } else {
        lbImg.style.display = 'none';
      }
      lbTitle.textContent = title || '';
      lbSub.textContent = sub || '';
      lightbox.classList.add('open');
      document.body.style.overflow = 'hidden';
    });
  });

  const closeLb = () => {
    lightbox.classList.remove('open');
    document.body.style.overflow = '';
  };

  lightbox.querySelector('.lightbox-close').addEventListener('click', closeLb);
  lightbox.addEventListener('click', e => { if (e.target === lightbox) closeLb(); });
  document.addEventListener('keydown', e => { if (e.key === 'Escape') closeLb(); });
}

// Gallery filter
const filterBtns = document.querySelectorAll('.filter-btn');
if (filterBtns.length) {
  filterBtns.forEach(btn => {
    btn.addEventListener('click', () => {
      filterBtns.forEach(b => b.classList.remove('active'));
      btn.classList.add('active');
      const cat = btn.dataset.filter;
      document.querySelectorAll('.gallery-item').forEach(item => {
        const show = cat === 'all' || item.dataset.cat === cat;
        item.style.display = show ? '' : 'none';
      });
    });
  });
}

// Contact form
const form = document.getElementById('contactForm');
if (form) {
  form.addEventListener('submit', async e => {
    e.preventDefault();
    const btn = form.querySelector('button[type="submit"]');
    const errorEl = document.getElementById('formError');
    if (errorEl) errorEl.style.display = 'none';
    btn.disabled = true;
    const originalText = btn.textContent;
    btn.textContent = 'Sending...';
    let error = null;
    try {
      ({ error } = await supabase.from('contact_submissions').insert({
        first_name: form.fname.value,
        last_name: form.lname.value,
        email: form.email.value,
        phone: form.phone.value || null,
        subject: form.subject.value,
        message: form.message.value
      }));
    } catch (err) {
      error = err;
    }
    if (error) {
      btn.textContent = originalText;
      btn.disabled = false;
      if (errorEl) errorEl.style.display = 'block';
    } else {
      btn.textContent = 'Message Sent';
      btn.style.background = '#1a5c1a';
      btn.style.borderColor = '#1a5c1a';
      setTimeout(() => {
        btn.textContent = originalText;
        btn.style.background = '';
        btn.style.borderColor = '';
        btn.disabled = false;
        form.reset();
      }, 3000);
    }
  });
}
