import os

def create_svgs():
    output_dir = "/home/david/Music/Bible Quiz/assets/icons/luxury"
    os.makedirs(output_dir, exist_ok=True)

    # Common gradient and glow definitions
    defs_block = """  <defs>
    <!-- Gold Gradient -->
    <linearGradient id="gold_grad" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#FFE082" />
      <stop offset="50%" stop-color="#FFD54F" />
      <stop offset="100%" stop-color="#FF8F00" />
    </linearGradient>
    
    <!-- Light Gold Gradient -->
    <linearGradient id="light_gold" x1="0%" y1="0%" x2="0%" y2="100%">
      <stop offset="0%" stop-color="#FFF9C4" />
      <stop offset="100%" stop-color="#FFE082" />
    </linearGradient>

    <!-- Blue Gradient -->
    <linearGradient id="blue_grad" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#80D8FF" />
      <stop offset="100%" stop-color="#2979FF" />
    </linearGradient>
    
    <!-- Dark Blue Gradient -->
    <linearGradient id="dark_blue" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#1A237E" />
      <stop offset="100%" stop-color="#0D47A1" />
    </linearGradient>

    <!-- Green Gradient -->
    <linearGradient id="green_grad" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#A5D6A7" />
      <stop offset="100%" stop-color="#2E7D32" />
    </linearGradient>

    <!-- Purple Gradient -->
    <linearGradient id="purple_grad" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#E1BEE7" />
      <stop offset="100%" stop-color="#7B1FA2" />
    </linearGradient>

    <!-- Teal Gradient -->
    <linearGradient id="teal_grad" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#B2DFDB" />
      <stop offset="100%" stop-color="#00796B" />
    </linearGradient>

    <!-- Orange Gradient -->
    <linearGradient id="orange_grad" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#FFCC80" />
      <stop offset="100%" stop-color="#E65100" />
    </linearGradient>

    <!-- Crimson Gradient -->
    <linearGradient id="crimson_grad" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#FF8A80" />
      <stop offset="100%" stop-color="#C62828" />
    </linearGradient>
    
    <!-- Background Glows -->
    <radialGradient id="gold_glow" cx="50%" cy="50%" r="50%">
      <stop offset="0%" stop-color="#FFD54F" stop-opacity="0.25" />
      <stop offset="100%" stop-color="#FFD54F" stop-opacity="0.0" />
    </radialGradient>
    <radialGradient id="blue_glow" cx="50%" cy="50%" r="50%">
      <stop offset="0%" stop-color="#2979FF" stop-opacity="0.25" />
      <stop offset="100%" stop-color="#2979FF" stop-opacity="0.0" />
    </radialGradient>
    <radialGradient id="green_glow" cx="50%" cy="50%" r="50%">
      <stop offset="0%" stop-color="#81C784" stop-opacity="0.25" />
      <stop offset="100%" stop-color="#81C784" stop-opacity="0.0" />
    </radialGradient>
    <radialGradient id="purple_glow" cx="50%" cy="50%" r="50%">
      <stop offset="0%" stop-color="#BA68C8" stop-opacity="0.25" />
      <stop offset="100%" stop-color="#BA68C8" stop-opacity="0.0" />
    </radialGradient>
    <radialGradient id="teal_glow" cx="50%" cy="50%" r="50%">
      <stop offset="0%" stop-color="#4DB6AC" stop-opacity="0.25" />
      <stop offset="100%" stop-color="#4DB6AC" stop-opacity="0.0" />
    </radialGradient>
    <radialGradient id="orange_glow" cx="50%" cy="50%" r="50%">
      <stop offset="0%" stop-color="#FFB74D" stop-opacity="0.25" />
      <stop offset="100%" stop-color="#FFB74D" stop-opacity="0.0" />
    </radialGradient>
    <radialGradient id="crimson_glow" cx="50%" cy="50%" r="50%">
      <stop offset="0%" stop-color="#FF8A80" stop-opacity="0.25" />
      <stop offset="100%" stop-color="#FF8A80" stop-opacity="0.0" />
    </radialGradient>
  </defs>"""

    # 1. Old Testament: Ancient stone tablets, Hebrew inscriptions, gold/amber
    svg_old_testament = f"""<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 256 256" width="256" height="256">
{defs_block}
  <!-- Glow Background -->
  <circle cx="128" cy="128" r="110" fill="url(#gold_glow)" />

  <g transform="translate(0, 0)">
    <!-- Left Tablet -->
    <path d="M 55 70 C 55 50, 120 50, 120 70 L 120 190 C 120 190, 55 190, 55 190 Z" 
          fill="url(#gold_grad)" stroke="#FFF9C4" stroke-width="2.5" stroke-linejoin="round" />
    <!-- Right Tablet -->
    <path d="M 136 70 C 136 50, 201 50, 201 70 L 201 190 C 201 190, 136 190, 136 190 Z" 
          fill="url(#gold_grad)" stroke="#FFF9C4" stroke-width="2.5" stroke-linejoin="round" />

    <!-- Inscriptions / Commandments Lines Left -->
    <line x1="70" y1="85" x2="105" y2="85" stroke="#FFF59D" stroke-width="3.5" stroke-linecap="round" opacity="0.8" />
    <line x1="70" y1="105" x2="100" y2="105" stroke="#FFF59D" stroke-width="3.5" stroke-linecap="round" opacity="0.8" />
    <line x1="70" y1="125" x2="105" y2="125" stroke="#FFF59D" stroke-width="3.5" stroke-linecap="round" opacity="0.8" />
    <line x1="70" y1="145" x2="95" y2="145" stroke="#FFF59D" stroke-width="3.5" stroke-linecap="round" opacity="0.8" />
    <line x1="70" y1="165" x2="102" y2="165" stroke="#FFF59D" stroke-width="3.5" stroke-linecap="round" opacity="0.8" />

    <!-- Inscriptions / Commandments Lines Right -->
    <line x1="151" y1="85" x2="186" y2="85" stroke="#FFF59D" stroke-width="3.5" stroke-linecap="round" opacity="0.8" />
    <line x1="151" y1="105" x2="181" y2="105" stroke="#FFF59D" stroke-width="3.5" stroke-linecap="round" opacity="0.8" />
    <line x1="151" y1="125" x2="186" y2="125" stroke="#FFF59D" stroke-width="3.5" stroke-linecap="round" opacity="0.8" />
    <line x1="151" y1="145" x2="176" y2="145" stroke="#FFF59D" stroke-width="3.5" stroke-linecap="round" opacity="0.8" />
    <line x1="151" y1="165" x2="183" y2="165" stroke="#FFF59D" stroke-width="3.5" stroke-linecap="round" opacity="0.8" />
  </g>
</svg>"""

    # 2. New Testament: Glowing scroll with cross, electric blue, rays
    svg_new_testament = f"""<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 256 256" width="256" height="256">
{defs_block}
  <!-- Glow Background -->
  <circle cx="128" cy="128" r="110" fill="url(#blue_glow)" />

  <g transform="translate(0, 0)">
    <!-- Ray Lines -->
    <line x1="128" y1="30" x2="128" y2="226" stroke="#80D8FF" stroke-width="1.5" opacity="0.2" stroke-dasharray="8,8" />
    <line x1="30" y1="128" x2="226" y2="128" stroke="#80D8FF" stroke-width="1.5" opacity="0.2" stroke-dasharray="8,8" />

    <!-- Scroll Sheet -->
    <path d="M 70 50 H 186 V 195 H 70 Z" fill="url(#blue_grad)" stroke="#FFFFFF" stroke-width="2" opacity="0.9"/>
    
    <!-- Top & Bottom Scroll Roll Cylinders -->
    <rect x="62" y="38" width="132" height="16" rx="8" fill="url(#dark_blue)" stroke="#80D8FF" stroke-width="2.5" />
    <rect x="62" y="191" width="132" height="16" rx="8" fill="url(#dark_blue)" stroke="#80D8FF" stroke-width="2.5" />
    
    <!-- Scroll Side Handles (Wood/Gold knobs) -->
    <circle cx="58" cy="46" r="6" fill="url(#gold_grad)" />
    <circle cx="198" cy="46" r="6" fill="url(#gold_grad)" />
    <circle cx="58" cy="199" r="6" fill="url(#gold_grad)" />
    <circle cx="198" cy="199" r="6" fill="url(#gold_grad)" />

    <!-- Embossed Glowing Gold Cross -->
    <g transform="translate(0, -6)">
      <!-- Vertical bar -->
      <rect x="120" y="80" width="16" height="66" rx="4" fill="url(#gold_grad)" stroke="#FFFFFF" stroke-width="1" />
      <!-- Horizontal bar -->
      <rect x="100" y="96" width="56" height="16" rx="4" fill="url(#gold_grad)" stroke="#FFFFFF" stroke-width="1" />
    </g>
  </g>
</svg>"""

    # 3. Quiz: Parchment with question mark, gold light, ink lines
    svg_quiz = f"""<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 256 256" width="256" height="256">
{defs_block}
  <!-- Glow Background -->
  <circle cx="128" cy="128" r="110" fill="url(#gold_glow)" />

  <g transform="translate(0, 0)">
    <!-- Parchment backing -->
    <path d="M 60 55 Q 128 45, 196 55 Q 206 128, 196 201 Q 128 211, 60 201 Q 50 128, 60 55 Z" 
          fill="url(#gold_grad)" stroke="#FFF59D" stroke-width="3" />
          
    <!-- Decorative border inlay -->
    <path d="M 68 63 Q 128 55, 188 63 Q 196 128, 188 193 Q 128 201, 68 193 Q 60 128, 68 63 Z" 
          fill="none" stroke="#FFF59D" stroke-width="1" opacity="0.6" stroke-dasharray="4,4" />

    <!-- Simulated text lines around the center -->
    <line x1="80" y1="80" x2="176" y2="80" stroke="#FFF59D" stroke-width="2" opacity="0.4" />
    <line x1="80" y1="92" x2="176" y2="92" stroke="#FFF59D" stroke-width="2" opacity="0.4" />
    <line x1="80" y1="164" x2="176" y2="164" stroke="#FFF59D" stroke-width="2" opacity="0.4" />
    <line x1="80" y1="176" x2="176" y2="176" stroke="#FFF59D" stroke-width="2" opacity="0.4" />

    <!-- Elegant Question Mark in center -->
    <path d="M 110 115 C 110 95, 146 95, 146 115 C 146 127, 128 132, 128 142 V 146" 
          fill="none" stroke="#FFFFFF" stroke-width="8" stroke-linecap="round" stroke-linejoin="round" />
    <circle cx="128" cy="158" r="5" fill="#FFFFFF" />
  </g>
</svg>"""

    # 4. Challenges: Golden trophy cup with divine glow, starburst
    svg_challenges = f"""<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 256 256" width="256" height="256">
{defs_block}
  <!-- Glow Background -->
  <circle cx="128" cy="128" r="110" fill="url(#gold_glow)" />

  <g transform="translate(0, 0)">
    <!-- Starburst Sparkles (luxury) -->
    <path d="M 128 25 L 131 40 L 146 43 L 131 46 L 128 61 L 125 46 L 110 43 L 125 40 Z" fill="#FFFFFF" opacity="0.9" />
    <path d="M 65 65 L 67 73 L 75 75 L 67 77 L 65 85 L 63 77 L 55 75 L 63 73 Z" fill="#FFE082" opacity="0.7" />
    <path d="M 191 65 L 193 73 L 201 75 L 193 77 L 191 85 L 189 77 L 181 75 L 189 73 Z" fill="#FFE082" opacity="0.7" />

    <!-- Trophy Cup Handles -->
    <path d="M 82 85 C 48 85, 48 135, 85 135" fill="none" stroke="url(#gold_grad)" stroke-width="5" stroke-linecap="round" />
    <path d="M 174 85 C 208 85, 208 135, 171 135" fill="none" stroke="url(#gold_grad)" stroke-width="5" stroke-linecap="round" />

    <!-- Trophy Stem and Base -->
    <path d="M 114 150 H 142 L 136 185 H 120 Z" fill="url(#gold_grad)" />
    <path d="M 90 185 H 166 C 166 185, 160 205, 128 205 C 96 205, 90 185, 90 185 Z" fill="url(#gold_grad)" stroke="#FFF9C4" stroke-width="2.5" />
    
    <!-- Trophy Main Bowl -->
    <path d="M 80 75 C 80 128, 96 152, 128 152 C 160 152, 176 128, 176 75 Z" fill="url(#gold_grad)" stroke="#FFF9C4" stroke-width="3.5" />
    <ellipse cx="128" cy="75" rx="48" ry="10" fill="url(#light_gold)" stroke="#FFFFFF" stroke-width="2" />
  </g>
</svg>"""

    # 5. Reading Plans: Open Bible with calendar page overlay, green/gold
    svg_reading_plans = f"""<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 256 256" width="256" height="256">
{defs_block}
  <!-- Glow Background -->
  <circle cx="128" cy="128" r="110" fill="url(#green_glow)" />

  <g transform="translate(0, 0)">
    <!-- Bible Base / Cover (Gold/Bronze) -->
    <path d="M 50 178 C 90 178, 128 188, 128 188 C 128 188, 166 178, 206 178 V 78 C 166 78, 128 88, 128 88 C 128 88, 90 78, 50 78 Z" 
          fill="#4E342E" stroke="url(#gold_grad)" stroke-width="3.5" />

    <!-- Bible Left Page (Light Green/Gold Gradient) -->
    <path d="M 55 173 C 90 173, 128 183, 128 183 V 83 C 128 83, 90 73, 55 73 Z" 
          fill="url(#green_grad)" stroke="#E8F5E9" stroke-width="1.5" />

    <!-- Bible Right Page (Light Green/Gold Gradient) -->
    <path d="M 201 173 C 166 173, 128 183, 128 183 V 83 C 128 83, 166 73, 201 73 Z" 
          fill="url(#green_grad)" stroke="#E8F5E9" stroke-width="1.5" />

    <!-- Page Text Lines (Left Page) -->
    <line x1="68" y1="95" x2="112" y2="95" stroke="#E8F5E9" stroke-width="2.5" opacity="0.6" stroke-linecap="round" />
    <line x1="68" y1="110" x2="112" y2="110" stroke="#E8F5E9" stroke-width="2.5" opacity="0.6" stroke-linecap="round" />
    <line x1="68" y1="125" x2="105" y2="125" stroke="#E8F5E9" stroke-width="2.5" opacity="0.6" stroke-linecap="round" />
    <line x1="68" y1="140" x2="112" y2="140" stroke="#E8F5E9" stroke-width="2.5" opacity="0.6" stroke-linecap="round" />
    <line x1="68" y1="155" x2="98" y2="155" stroke="#E8F5E9" stroke-width="2.5" opacity="0.6" stroke-linecap="round" />

    <!-- Calendar Page Overlay (Overlaps Bottom Right) -->
    <g transform="translate(130, 95)">
      <!-- Calendar Card Background -->
      <rect x="0" y="0" width="65" height="65" rx="8" fill="#FFFFFF" stroke="url(#gold_grad)" stroke-width="2" />
      <!-- Calendar Top bar (Gold) -->
      <rect x="0" y="0" width="65" height="16" rx="2" fill="url(#gold_grad)" />
      <!-- Rings -->
      <circle cx="15" cy="0" r="3" fill="#3E2723" />
      <circle cx="32" cy="0" r="3" fill="#3E2723" />
      <circle cx="50" cy="0" r="3" fill="#3E2723" />
      
      <!-- Calendar Grid Mockup (Dots) -->
      <circle cx="15" cy="28" r="2.5" fill="#2E7D32" />
      <circle cx="32" cy="28" r="2.5" fill="#2E7D32" />
      <circle cx="50" cy="28" r="2.5" fill="#2E7D32" />
      <circle cx="15" cy="42" r="2.5" fill="#2E7D32" />
      <circle cx="32" cy="42" r="2.5" fill="#FF8F00" /> <!-- Highlights current reading day in gold -->
      <circle cx="50" cy="42" r="2.5" fill="#CCCCCC" />
      <circle cx="15" cy="54" r="2.5" fill="#CCCCCC" />
      <circle cx="32" cy="54" r="2.5" fill="#CCCCCC" />
      <circle cx="50" cy="54" r="2.5" fill="#CCCCCC" />
    </g>
  </g>
</svg>"""

    # 6. Scripture Memory: Glowing scripture scroll, amber light
    svg_scripture_memory = f"""<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 256 256" width="256" height="256">
{defs_block}
  <!-- Glow Background -->
  <circle cx="128" cy="128" r="110" fill="url(#orange_glow)" />

  <g transform="translate(0, 0)">
    <!-- Vertical Scroll Sheet -->
    <path d="M 72 45 Q 128 35, 184 45 V 205 Q 128 215, 72 205 Z" fill="url(#orange_grad)" stroke="#FFE082" stroke-width="2.5" />
    
    <!-- Top & Bottom Curl Cylinders -->
    <path d="M 64 35 Q 128 25, 192 35 C 192 35, 192 48, 192 48 Q 128 38, 64 48 Z" fill="#E65100" stroke="#FFE082" stroke-width="1.5" />
    <path d="M 64 201 Q 128 191, 192 201 C 192 201, 192 214, 192 214 Q 128 204, 64 214 Z" fill="#E65100" stroke="#FFE082" stroke-width="1.5" />

    <!-- Elegant Star sparkles on scroll -->
    <path d="M 128 65 L 130 72 L 137 74 L 130 76 L 128 83 L 126 76 L 119 74 L 126 72 Z" fill="#FFFFFF" />
    
    <!-- Glowing Scripture text lines (simulated with paths) -->
    <line x1="90" y1="100" x2="166" y2="100" stroke="#FFFFFF" stroke-width="4.5" stroke-linecap="round" opacity="0.9" />
    <line x1="90" y1="120" x2="166" y2="120" stroke="#FFFFFF" stroke-width="4.5" stroke-linecap="round" opacity="0.9" />
    <line x1="90" y1="140" x2="150" y2="140" stroke="#FFFFFF" stroke-width="4.5" stroke-linecap="round" opacity="0.9" />
    
    <!-- Heart outline embossed at the bottom (representing memory/retention in heart) -->
    <path d="M 128 180 C 128 180, 115 168, 115 160 C 115 154, 120 150, 128 158 C 136 150, 141 154, 141 160 C 141 168, 128 180, 128 180 Z" 
          fill="none" stroke="#FFFFFF" stroke-width="2.5" stroke-linejoin="round" />
  </g>
</svg>"""

    # 7. Quiz Creator: Crossed puzzle piece and quill, purple and gold
    svg_quiz_creator = f"""<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 256 256" width="256" height="256">
{defs_block}
  <!-- Glow Background -->
  <circle cx="128" cy="128" r="110" fill="url(#purple_glow)" />

  <g transform="translate(0, 0)">
    <!-- Puzzle Piece (Purple) -->
    <!-- Simplified geometric path for puzzle piece: center square with circular tabs/blanks -->
    <path d="M 80 80 
             H 105 C 105 92, 123 92, 123 80 
             H 148 V 105 C 160 105, 160 123, 148 123 
             V 148 H 123 C 123 136, 105 136, 105 148 
             H 80 V 123 C 68 123, 68 105, 80 105 Z" 
          fill="url(#purple_grad)" stroke="#E1BEE7" stroke-width="2.5" stroke-linejoin="round" />

    <!-- Elegant Quill Pen (Crossed diagonally) -->
    <g transform="rotate(45, 128, 128)">
      <!-- Feathers -->
      <path d="M 124 50 C 120 70, 105 110, 124 160 V 175 L 128 185 L 132 175 V 160 C 151 110, 136 70, 132 50 Z" 
            fill="url(#gold_grad)" stroke="#FFF9C4" stroke-width="1.5" />
      <!-- Quill center line -->
      <line x1="128" y1="45" x2="128" y2="185" stroke="#FFFFFF" stroke-width="2" />
      <!-- Feather notches -->
      <path d="M 124 75 L 115 78 M 124 95 L 110 100 M 124 115 L 112 122" stroke="#FFF9C4" stroke-width="1.5" stroke-linecap="round" />
      <path d="M 132 75 L 141 78 M 132 95 L 146 100 M 132 115 L 144 122" stroke="#FFF9C4" stroke-width="1.5" stroke-linecap="round" />
    </g>
  </g>
</svg>"""

    # 8. Leaderboard: Royal podium with rankings and crown, blue and gold
    svg_leaderboard = f"""<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 256 256" width="256" height="256">
{defs_block}
  <!-- Glow Background -->
  <circle cx="128" cy="128" r="110" fill="url(#blue_glow)" />

  <g transform="translate(0, 0)">
    <!-- Podium Bars -->
    <!-- 2nd Place Bar (Left) -->
    <rect x="55" y="120" width="42" height="75" rx="8" fill="url(#blue_grad)" stroke="#E0F7FA" stroke-width="2" />
    <!-- 1st Place Bar (Center) -->
    <rect x="107" y="90" width="42" height="105" rx="8" fill="url(#blue_grad)" stroke="#E0F7FA" stroke-width="2" />
    <!-- 3rd Place Bar (Right) -->
    <rect x="159" y="140" width="42" height="55" rx="8" fill="url(#blue_grad)" stroke="#E0F7FA" stroke-width="2" />

    <!-- Ranking Numbers on Podium -->
    <text x="76" y="165" font-family="'Outfit', sans-serif" font-weight="bold" font-size="22" fill="#FFFFFF" text-anchor="middle">2</text>
    <text x="128" y="150" font-family="'Outfit', sans-serif" font-weight="bold" font-size="26" fill="#FFD54F" text-anchor="middle">1</text>
    <text x="180" y="175" font-family="'Outfit', sans-serif" font-weight="bold" font-size="20" fill="#FFFFFF" text-anchor="middle">3</text>

    <!-- Royal Golden Crown on 1st Place -->
    <g transform="translate(109, 48)">
      <path d="M 2 30 L 7 12 L 18 20 L 29 10 L 40 20 L 51 12 L 56 30 Z" fill="url(#gold_grad)" stroke="#FFFFFF" stroke-width="1.5" />
      <rect x="0" y="27" width="58" height="5" rx="2" fill="url(#gold_grad)" />
      <!-- Jewels on crown peaks -->
      <circle cx="7" cy="12" r="2" fill="#FFFFFF" />
      <circle cx="29" cy="10" r="2.5" fill="#FF8F00" />
      <circle cx="51" cy="12" r="2" fill="#FFFFFF" />
    </g>
  </g>
</svg>"""

    # 9. Prayer Wall: Praying hands, warm light between, teal
    svg_prayer_wall = f"""<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 256 256" width="256" height="256">
{defs_block}
  <!-- Glow Background -->
  <circle cx="128" cy="128" r="110" fill="url(#teal_glow)" />

  <g transform="translate(0, 0)">
    <!-- Light Radiating between palms -->
    <circle cx="128" cy="115" r="25" fill="url(#gold_glow)" />
    
    <!-- Praying Hands (Symmetric elegant silhouettes) -->
    <!-- Left Hand -->
    <path d="M 80 195 
             C 80 195, 88 140, 108 115 
             C 118 102, 124 95, 126 80
             C 126 80, 128 85, 126 95
             C 123 105, 118 120, 120 135
             C 122 150, 110 175, 110 175 Z" 
          fill="url(#teal_grad)" stroke="#E0F2F1" stroke-width="2" stroke-linejoin="round" />

    <!-- Right Hand -->
    <path d="M 176 195 
             C 176 195, 168 140, 148 115 
             C 138 102, 132 95, 130 80
             C 130 80, 128 85, 130 95
             C 133 105, 138 120, 136 135
             C 134 150, 146 175, 146 175 Z" 
          fill="url(#teal_grad)" stroke="#E0F2F1" stroke-width="2" stroke-linejoin="round" />

    <!-- Soft Sparkles -->
    <path d="M 128 65 L 130 70 L 135 71 L 130 72 L 128 77 L 126 72 L 121 71 L 126 70 Z" fill="#FFE082" />
  </g>
</svg>"""

    # 10. Social Feed: Connected figures in a circle, orange and gold
    svg_social_feed = f"""<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 256 256" width="256" height="256">
{defs_block}
  <!-- Glow Background -->
  <circle cx="128" cy="128" r="110" fill="url(#orange_glow)" />

  <g transform="translate(0, 0)">
    <!-- Connection Circle Paths -->
    <circle cx="128" cy="128" r="62" fill="none" stroke="url(#gold_grad)" stroke-width="2" stroke-dasharray="6,6" />

    <!-- Connected Figures (Nodes) -->
    <!-- Top Node -->
    <g transform="translate(128, 66)">
      <circle cx="0" cy="0" r="14" fill="url(#orange_grad)" stroke="#FFFFFF" stroke-width="2" />
      <circle cx="0" cy="-6" r="4.5" fill="#FFFFFF" />
      <path d="M -8 8 C -8 4, 8 4, 8 8 Z" fill="#FFFFFF" />
    </g>

    <!-- Bottom Node -->
    <g transform="translate(128, 190)">
      <circle cx="0" cy="0" r="14" fill="url(#orange_grad)" stroke="#FFFFFF" stroke-width="2" />
      <circle cx="0" cy="-6" r="4.5" fill="#FFFFFF" />
      <path d="M -8 8 C -8 4, 8 4, 8 8 Z" fill="#FFFFFF" />
    </g>

    <!-- Left Node -->
    <g transform="translate(66, 128)">
      <circle cx="0" cy="0" r="14" fill="url(#orange_grad)" stroke="#FFFFFF" stroke-width="2" />
      <circle cx="0" cy="-6" r="4.5" fill="#FFFFFF" />
      <path d="M -8 8 C -8 4, 8 4, 8 8 Z" fill="#FFFFFF" />
    </g>

    <!-- Right Node -->
    <g transform="translate(190, 128)">
      <circle cx="0" cy="0" r="14" fill="url(#orange_grad)" stroke="#FFFFFF" stroke-width="2" />
      <circle cx="0" cy="-6" r="4.5" fill="#FFFFFF" />
      <path d="M -8 8 C -8 4, 8 4, 8 8 Z" fill="#FFFFFF" />
    </g>

    <!-- Top-Right Node -->
    <g transform="translate(172, 84)">
      <circle cx="0" cy="0" r="10" fill="url(#gold_grad)" stroke="#FFFFFF" stroke-width="1.5" />
    </g>
    <!-- Bottom-Left Node -->
    <g transform="translate(84, 172)">
      <circle cx="0" cy="0" r="10" fill="url(#gold_grad)" stroke="#FFFFFF" stroke-width="1.5" />
    </g>
  </g>
</svg>"""

    # 11. Wisdom Tree: Majestic tree with elegant branches, gold and amber
    svg_wisdom_tree = f"""<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 256 256" width="256" height="256">
{defs_block}
  <!-- Glow Background -->
  <circle cx="128" cy="128" r="110" fill="url(#gold_glow)" />

  <g transform="translate(0, 0)">
    <!-- Tree Leaves (Outer Glowing Circles) -->
    <circle cx="128" cy="85" r="36" fill="url(#gold_grad)" opacity="0.15" />
    <circle cx="98" cy="105" r="28" fill="url(#gold_grad)" opacity="0.15" />
    <circle cx="158" cy="105" r="28" fill="url(#gold_grad)" opacity="0.15" />

    <!-- Tree Trunk & Main Branches -->
    <path d="M 120 205 L 124 165 C 124 165, 100 135, 95 110 C 90 85, 120 90, 120 90 C 120 90, 115 115, 128 135 C 141 115, 136 90, 136 90 C 136 90, 166 85, 161 110 C 156 135, 132 165, 132 165 L 136 205 Z" 
          fill="url(#orange_grad)" stroke="#FFE082" stroke-width="1.5" />

    <!-- Tree Root/Soil Base line -->
    <path d="M 85 205 Q 128 198, 171 205" fill="none" stroke="#FFE082" stroke-width="3.5" stroke-linecap="round" />
    
    <!-- Leaves (Small Gold Circles) -->
    <circle cx="128" cy="65" r="7" fill="#FFFFFF" />
    <circle cx="108" cy="78" r="6" fill="#FFF9C4" />
    <circle cx="148" cy="78" r="6" fill="#FFF9C4" />
    <circle cx="90" cy="98" r="7" fill="#FFD54F" />
    <circle cx="166" cy="98" r="7" fill="#FFD54F" />
    <circle cx="108" cy="115" r="5" fill="#FFE082" />
    <circle cx="148" cy="115" r="5" fill="#FFE082" />
    <circle cx="128" cy="98" r="8" fill="url(#gold_grad)" stroke="#FFFFFF" stroke-width="1" />
  </g>
</svg>"""

    # 12. Bookmarks: Ribbon bookmark, crimson and gold
    svg_bookmarks = f"""<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 256 256" width="256" height="256">
{defs_block}
  <!-- Glow Background -->
  <circle cx="128" cy="128" r="110" fill="url(#crimson_glow)" />

  <g transform="translate(0, 0)">
    <!-- Back loop of ribbon (representing book pages/binder) -->
    <path d="M 88 55 H 168 C 168 55, 168 75, 128 75 C 88 75, 88 55, 88 55 Z" fill="#990000" stroke="#FF8A80" stroke-width="1.5" />

    <!-- Main Hanging Ribbon Banner (Crimson) -->
    <path d="M 98 65 H 158 V 195 L 128 175 L 98 195 Z" fill="url(#crimson_grad)" stroke="#FF8A80" stroke-width="2.5" stroke-linejoin="round" />

    <!-- Gold Border Stripes inside Ribbon -->
    <path d="M 106 65 V 173 L 128 158 L 150 173 V 65" fill="none" stroke="url(#gold_grad)" stroke-width="2" />
    
    <!-- Holy Cross Logo embossed on ribbon -->
    <g transform="translate(128, 105)">
      <rect x="-4" y="-18" width="8" height="36" rx="2" fill="url(#gold_grad)" stroke="#FFFFFF" stroke-width="0.5" />
      <rect x="-14" y="-8" width="28" height="8" rx="2" fill="url(#gold_grad)" stroke="#FFFFFF" stroke-width="0.5" />
    </g>
  </g>
</svg>"""

    # 13. Favorites: Radiant 8-pointed star with sparkles, gold
    svg_favorites = f"""<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 256 256" width="256" height="256">
{defs_block}
  <!-- Glow Background -->
  <circle cx="128" cy="128" r="110" fill="url(#gold_glow)" />

  <g transform="translate(0, 0)">
    <!-- Background Outer Light Rays -->
    <line x1="128" y1="35" x2="128" y2="221" stroke="#FFD54F" stroke-width="1.5" opacity="0.3" stroke-dasharray="10,10" />
    <line x1="35" y1="128" x2="221" y2="128" stroke="#FFD54F" stroke-width="1.5" opacity="0.3" stroke-dasharray="10,10" />
    <line x1="62" y1="62" x2="194" y2="194" stroke="#FFD54F" stroke-width="1.5" opacity="0.2" stroke-dasharray="10,10" />
    <line x1="62" y1="194" x2="194" y2="62" stroke="#FFD54F" stroke-width="1.5" opacity="0.2" stroke-dasharray="10,10" />

    <!-- Luxury 8-pointed Star -->
    <path d="M 128 48 
             L 138 98 L 188 108 L 138 118 
             L 128 168 L 118 118 L 68 108 L 118 98 Z" 
          fill="url(#gold_grad)" stroke="#FFFFFF" stroke-width="2.5" stroke-linejoin="round" />
    <path d="M 128 78 
             L 132 104 L 158 108 L 132 112 
             L 128 138 L 124 112 L 98 108 L 124 104 Z" 
          fill="url(#light_gold)" />

    <!-- Extra Sparkles around -->
    <path d="M 85 85 L 87 90 L 92 91 L 87 92 L 85 97 L 83 92 L 78 91 L 83 90 Z" fill="#FFFFFF" opacity="0.8" />
    <path d="M 171 171 L 173 176 L 178 177 L 173 178 L 171 183 L 169 178 L 164 177 L 169 176 Z" fill="#FFFFFF" opacity="0.8" />
    <circle cx="178" cy="85" r="3.5" fill="#FFE082" />
    <circle cx="85" cy="171" r="3" fill="#FFE082" />
  </g>
</svg>"""

    # Writing all files
    svgs = {
        "old_testament.svg": svg_old_testament,
        "new_testament.svg": svg_new_testament,
        "quiz.svg": svg_quiz,
        "challenges.svg": svg_challenges,
        "reading_plans.svg": svg_reading_plans,
        "scripture_memory.svg": svg_scripture_memory,
        "quiz_creator.svg": svg_quiz_creator,
        "leaderboard.svg": svg_leaderboard,
        "prayer_wall.svg": svg_prayer_wall,
        "social_feed.svg": svg_social_feed,
        "wisdom_tree.svg": svg_wisdom_tree,
        "bookmarks.svg": svg_bookmarks,
        "favorites.svg": svg_favorites
    }

    for name, content in svgs.items():
        file_path = os.path.join(output_dir, name)
        with open(file_path, "w", encoding="utf-8") as f:
            f.write(content)
        print(f"Created SVG: {file_path}")

if __name__ == "__main__":
    create_svgs()
