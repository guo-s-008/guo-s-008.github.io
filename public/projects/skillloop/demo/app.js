document.addEventListener("DOMContentLoaded", () => {
  lucide.createIcons();

  const publishDialog = document.querySelector("#publishDialog");
  const swapDialog = document.querySelector("#swapDialog");
  const publishForm = document.querySelector("#publishForm");
  const swapForm = document.querySelector("#swapForm");
  const toast = document.querySelector("#toast");
  const cards = [...document.querySelectorAll(".match-card")];
  const emptyState = document.querySelector("#emptyState");
  const searchInput = document.querySelector("#heroSearch");
  let activeCategory = "全部";

  const showToast = (message) => {
    toast.querySelector("span").textContent = message;
    toast.classList.add("show");
    window.setTimeout(() => toast.classList.remove("show"), 2600);
  };

  const filterCards = () => {
    const query = searchInput.value.trim().toLowerCase();
    let visibleCount = 0;

    cards.forEach((card) => {
      const categoryMatches = activeCategory === "全部" || card.dataset.category === activeCategory;
      const queryMatches = !query || card.dataset.keywords.toLowerCase().includes(query);
      const isVisible = categoryMatches && queryMatches;
      card.hidden = !isVisible;
      if (isVisible) visibleCount += 1;
    });

    emptyState.hidden = visibleCount !== 0;
    document.querySelector("#matches").scrollIntoView({ behavior: "smooth" });
  };

  document.querySelectorAll("[data-open-publish]").forEach((button) => {
    button.addEventListener("click", () => publishDialog.showModal());
  });

  document.querySelectorAll(".filter").forEach((button) => {
    button.addEventListener("click", () => {
      document.querySelector(".filter.active").classList.remove("active");
      button.classList.add("active");
      activeCategory = button.dataset.category;
      filterCards();
    });
  });

  document.querySelector("#searchButton").addEventListener("click", filterCards);
  searchInput.addEventListener("keydown", (event) => {
    if (event.key === "Enter") filterCards();
  });

  document.querySelectorAll(".save-button").forEach((button) => {
    button.addEventListener("click", () => {
      button.classList.toggle("saved");
      const saved = button.classList.contains("saved");
      button.setAttribute("aria-label", saved ? "取消收藏" : "收藏");
      showToast(saved ? "已加入收藏" : "已取消收藏");
    });
  });

  document.querySelectorAll(".swap-button").forEach((button) => {
    button.addEventListener("click", () => {
      document.querySelector("#swapTitle").textContent = `向 ${button.dataset.name} 发起交换`;
      document.querySelector("#selectedSkill").textContent = `想学：${button.dataset.skill}`;
      swapDialog.showModal();
    });
  });

  document.querySelector("#refreshMatches").addEventListener("click", () => {
    const grid = document.querySelector("#matchGrid");
    grid.append(...[...grid.children].reverse());
    showToast("已更新推荐顺序");
  });

  publishForm.addEventListener("submit", (event) => {
    event.preventDefault();
    publishDialog.close();
    publishForm.reset();
    showToast("技能档案已保存，正在为你寻找匹配");
  });

  swapForm.addEventListener("submit", (event) => {
    event.preventDefault();
    swapDialog.close();
    swapForm.reset();
    showToast("交换申请已发送");
  });

  [publishDialog, swapDialog].forEach((dialog) => {
    dialog.addEventListener("click", (event) => {
      if (event.target === dialog) dialog.close();
    });
  });
});
