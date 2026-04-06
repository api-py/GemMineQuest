#!/usr/bin/env python3
"""Remove fake transparency checkerboard from ALL Firefly PNG images - handles dark and light checkerboard."""

import os
from PIL import Image
import numpy as np
from scipy import ndimage

def detect_checkerboard_colors(data, check_size=8):
    """Detect the two alternating colors used in the checkerboard pattern."""
    h, w = data.shape[:2]
    # Sample from corners (which should be background)
    margin = min(20, h//4, w//4)

    corner_regions = [
        data[:margin, :margin, :3],        # top-left
        data[:margin, -margin:, :3],       # top-right
        data[-margin:, :margin, :3],       # bottom-left
        data[-margin:, -margin:, :3],      # bottom-right
    ]

    all_corner_pixels = np.concatenate([r.reshape(-1, 3) for r in corner_regions])

    if len(all_corner_pixels) < 10:
        return None, None

    # Check if corners are grey-ish (R≈G≈B)
    diffs = np.max(all_corner_pixels, axis=1) - np.min(all_corner_pixels, axis=1)
    grey_mask = diffs < 20
    grey_pixels = all_corner_pixels[grey_mask]

    if len(grey_pixels) < len(all_corner_pixels) * 0.5:
        return None, None  # Corners aren't mostly grey - probably not checkerboard

    # Find the two cluster centers (light and dark squares)
    brightness = grey_pixels.mean(axis=1)
    median_b = np.median(brightness)

    light_pixels = grey_pixels[brightness >= median_b]
    dark_pixels = grey_pixels[brightness < median_b]

    if len(light_pixels) < 5 or len(dark_pixels) < 5:
        # All same brightness - single color background
        color1 = grey_pixels.mean(axis=0)
        return color1, color1

    color1 = light_pixels.mean(axis=0)  # Light square color
    color2 = dark_pixels.mean(axis=0)   # Dark square color

    # Verify they differ enough to be a checkerboard
    if abs(float(color1.mean()) - float(color2.mean())) < 5:
        # Same color, just solid background
        color1 = grey_pixels.mean(axis=0)
        return color1, color1

    return color1, color2


def remove_background(image_path, output_path):
    """Remove grey checkerboard background using flood fill from edges."""
    img = Image.open(image_path).convert('RGBA')
    data = np.array(img)
    h, w = data.shape[:2]

    # Skip very small images
    if h < 10 or w < 10:
        return False

    # Detect checkerboard colors
    color1, color2 = detect_checkerboard_colors(data)
    if color1 is None:
        return False

    r, g, b = data[:,:,0].astype(float), data[:,:,1].astype(float), data[:,:,2].astype(float)

    # Create mask: pixel is "background-like" if close to either checkerboard color
    threshold = 25  # color distance threshold

    dist1 = np.sqrt((r - color1[0])**2 + (g - color1[1])**2 + (b - color1[2])**2)
    dist2 = np.sqrt((r - color2[0])**2 + (g - color2[1])**2 + (b - color2[2])**2)

    # Also check grey-ness (R≈G≈B)
    is_grey = (np.abs(r - g) < 18) & (np.abs(g - b) < 18) & (np.abs(r - b) < 18)

    is_bg_like = is_grey & ((dist1 < threshold) | (dist2 < threshold))

    # Flood fill from all edges
    labeled, num_features = ndimage.label(is_bg_like)

    edge_labels = set()
    edge_labels.update(labeled[0, :].flatten())
    edge_labels.update(labeled[-1, :].flatten())
    edge_labels.update(labeled[:, 0].flatten())
    edge_labels.update(labeled[:, -1].flatten())
    # Also check 1px inside edges for robustness
    if h > 2 and w > 2:
        edge_labels.update(labeled[1, :].flatten())
        edge_labels.update(labeled[-2, :].flatten())
        edge_labels.update(labeled[:, 1].flatten())
        edge_labels.update(labeled[:, -2].flatten())
    edge_labels.discard(0)

    bg_mask = np.isin(labeled, list(edge_labels))

    if bg_mask.sum() < 50:
        # Very little background detected - try expanding
        # Maybe the subject touches edges, use all matching regions
        for label_id in range(1, num_features + 1):
            region = labeled == label_id
            region_size = region.sum()
            # Only include large background regions
            if region_size > 200:
                bg_mask |= region

    if bg_mask.sum() < 20:
        return False  # No significant background to remove

    # Apply transparency
    alpha = data[:,:,3].copy()
    alpha[bg_mask] = 0

    # Anti-alias edges: pixels bordering the background
    border = ndimage.binary_dilation(bg_mask, iterations=1) & ~bg_mask
    # For border pixels that are grey-ish, reduce alpha for smooth edges
    border_grey = border & is_grey
    alpha[border_grey] = np.clip(alpha[border_grey].astype(int) // 2, 0, 255).astype(np.uint8)

    data[:,:,3] = alpha

    result = Image.fromarray(data)
    result.save(output_path, optimize=True)
    return True


def process_all():
    assets_dir = '/Users/ssddgreg/game/GemMineQuest/Assets.xcassets'

    categories = [
        'Gems', 'Specials', 'Blockers', 'Icons', 'Boosters', 'UI',
        'Buttons', 'Character', 'LevelMap', 'Tiles', 'Particles'
    ]
    # NOTE: Backgrounds intentionally excluded - they should NOT be transparent

    total = 0
    for cat in categories:
        cat_dir = os.path.join(assets_dir, cat)
        if not os.path.exists(cat_dir):
            continue
        print(f"\n=== {cat} ===")
        for root, dirs, files in os.walk(cat_dir):
            for f in files:
                if not f.lower().endswith('.png'):
                    continue
                filepath = os.path.join(root, f)

                # Skip background images that should stay opaque
                if any(skip in f for skip in ['bg_', 'tile_light', 'tile_dark']):
                    print(f"  {f}: SKIP (should be opaque)")
                    continue

                # Re-copy from originals first to get clean source
                # (some were already partially processed by v1)

                try:
                    fixed = remove_background(filepath, filepath)
                    if fixed:
                        total += 1
                        print(f"  {f}: FIXED")
                    else:
                        print(f"  {f}: no bg detected")
                except Exception as e:
                    print(f"  {f}: ERROR - {e}")

    print(f"\nTotal fixed: {total}")


if __name__ == '__main__':
    process_all()
