const config = { owner: 'King-pe', repo: 'termux-guardian' };
const toast = document.querySelector('.toast');
let toastTimer;

function showToast(message = 'Copied to clipboard') {
  toast.textContent = message;
  toast.classList.add('show');
  clearTimeout(toastTimer);
  toastTimer = setTimeout(() => toast.classList.remove('show'), 1800);
}

document.querySelectorAll('[data-copy]').forEach((button) => {
  button.addEventListener('click', async () => {
    const value = button.dataset.copy;
    try {
      await navigator.clipboard.writeText(value);
      showToast();
    } catch {
      showToast('Copy unavailable — select the command manually');
    }
  });
});

const links = [...document.querySelectorAll('.rail-link')];
const sections = [...document.querySelectorAll('.section-anchor')];
const observer = new IntersectionObserver((entries) => {
  const visible = entries.filter((entry) => entry.isIntersecting).sort((a, b) => b.intersectionRatio - a.intersectionRatio)[0];
  if (!visible) return;
  const id = visible.target.id;
  links.forEach((link) => link.classList.toggle('active', link.getAttribute('href') === `#${id}`));
}, { rootMargin: '-20% 0px -60% 0px', threshold: [0.05, 0.3, 0.7] });
sections.forEach((section) => observer.observe(section));

async function loadPublicMetrics() {
  const status = document.querySelector('#metrics-status');
  document.querySelector('#repo-name').textContent = `${config.owner} / ${config.repo}`;
  try {
    const response = await fetch(`https://api.github.com/repos/${config.owner}/${config.repo}`, { headers: { Accept: 'application/vnd.github+json' } });
    if (!response.ok) throw new Error(`GitHub API status ${response.status}`);
    const data = await response.json();
    document.querySelector('#forks').textContent = String(data.forks_count ?? 'N/A');
    document.querySelector('#stars').textContent = String(data.stargazers_count ?? 'N/A');
    document.querySelector('#watchers').textContent = String(data.subscribers_count ?? data.watchers_count ?? 'N/A');
    document.querySelector('#issues').textContent = String(data.open_issues_count ?? 'N/A');
    document.querySelector('#updated').textContent = data.updated_at ? new Date(data.updated_at).toLocaleDateString('en-GB', { day: '2-digit', month: 'short', year: 'numeric' }).toUpperCase() : 'N/A';
    status.textContent = 'PUBLIC DATA / LIVE';
    status.style.color = 'var(--cyan)';
  } catch {
    ['forks', 'stars', 'watchers', 'issues', 'updated'].forEach((id) => { document.querySelector(`#${id}`).textContent = 'N/A'; });
    status.textContent = 'PUBLIC DATA / UNAVAILABLE';
  }
}
loadPublicMetrics();
