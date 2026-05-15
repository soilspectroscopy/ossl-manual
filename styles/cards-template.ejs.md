```{=html}
<div class="list ossl-card-grid">
<% for (const item of items) { %>
  <a href="<%- item.path %>" class="ossl-card-link" <%= metadataAttrs(item) %>>
    <article class="ossl-card">
      <div class="ossl-card-band" style="background-color: <%= item.band_color || '#f1f3f5' %>;">
        <img src="<%- item.image %>" alt="<%= item.title %> logo" class="ossl-card-logo" />
      </div>

      <div class="ossl-card-body">
        <p class="ossl-card-desc"><%= item.description %></p>

        
        <div class="ossl-pill-row" aria-label="Spectral ranges available">
          <span class="ossl-pill <%= (item.has_vnir === true || item.has_vnir === 'yes') ? 'ossl-pill-on' : 'ossl-pill-off' %>">VNIR</span>
          <span class="ossl-pill <%= (item.has_nir === true || item.has_nir === 'yes') ? 'ossl-pill-on' : 'ossl-pill-off' %>">NIR</span>
          <span class="ossl-pill <%= (item.has_mir === true || item.has_mir === 'yes') ? 'ossl-pill-on' : 'ossl-pill-off' %>">MIR</span>
        </div>

        <div class="ossl-extent">
          <i class="bi bi-globe-americas" aria-hidden="true"></i>
          <span><%= item.extent %></span>
        </div>

        <dl class="ossl-stats">
          <dt><i class="bi bi-database" aria-hidden="true"></i>Sample size</dt>
          <dd><%= item.sample_size %></dd>
          <dt><i class="bi bi-calendar3" aria-hidden="true"></i>Version</dt>
          <dd><%= item.version %></dd>
        </dl>

        <div class="ossl-cta">
          <span>View dataset</span>
          <i class="bi bi-arrow-right" aria-hidden="true"></i>
        </div>
      </div>
    </article>
  </a>
<% } %>
</div>
```
