#!/usr/bin/env python3
"""Remove fake transparency checkerboard from Firefly-generated PNG images."""

import os
import sys
from PIL import Image
import numpy as np

def remove_checkerboard(image_path, output_path):
    """Remove the grey/white checkerboard background from an image."""
    img = Image.open(image_path).convert('RGBA')
    data = np.array(img)

    h, w = data.shape[:2]

    # The checkerboard pattern alternates between light grey and white
    # Typical checkerboard colors: ~(204,204,204) and ~(255,255,255)
    # or ~(192,192,192) and ~(255,255,255)
    # The check size is usually 8x8 or 16x16 pixels

    # Strategy: Use flood fill from edges to find and remove background
    # This is safer than pattern matching since it won't remove interior pixels

    # First, detect if the image has actual alpha already
    if data[:,:,3].min() < 250:
        # Image already has some transparency, might be partially correct
        # Still try to clean up checkerboard areas
        pass

    # Create a mask of pixels that look like checkerboard
    r, g, b, a = data[:,:,0], data[:,:,1], data[:,:,2], data[:,:,3]

    # Checkerboard pixels are grey-ish (R≈G≈B) and either light or dark
    is_grey = (np.abs(r.astype(int) - g.astype(int)) < 15) & \
              (np.abs(g.astype(int) - b.astype(int)) < 15) & \
              (np.abs(r.astype(int) - b.astype(int)) < 15)

    # Light squares: roughly (240-255, 240-255, 240-255)
    is_light = is_grey & (r > 235) & (g > 235) & (b > 235)

    # Dark squares: roughly (190-210, 190-210, 190-210)
    is_dark_checker = is_grey & (r > 185) & (r < 215) & (g > 185) & (g < 215)

    is_checker = is_light | is_dark_checker

    # Use flood fill from all edges to find connected checkerboard regions
    from scipy import ndimage

    # Label connected components of checkerboard-like pixels
    labeled, num_features = ndimage.label(is_checker)

    # Find which labels touch the edges
    edge_labels = set()
    if h > 0 and w > 0:
        edge_labels.update(labeled[0, :].flatten())      # top
        edge_labels.update(labeled[-1, :].flatten())     # bottom
        edge_labels.update(labeled[:, 0].flatten())      # left
        edge_labels.update(labeled[:, -1].flatten())     # right
    edge_labels.discard(0)  # 0 = not a checkerboard pixel

    # Create mask of background checkerboard (connected to edges)
    bg_mask = np.isin(labeled, list(edge_labels))

    # Also handle case where there's no edge-connected region but the corners
    # are clearly checkerboard - use a simpler approach for those images
    corner_pixels = [
        data[0, 0, :3], data[0, -1, :3],
        data[-1, 0, :3], data[-1, -1, :3],
        data[2, 2, :3], data[2, -3, :3],
        data[-3, 2, :3], data[-3, -3, :3],
    ]

    corners_are_checker = sum(1 for p in corner_pixels
                              if abs(int(p[0]) - int(p[1])) < 15 and
                                 abs(int(p[1]) - int(p[2])) < 15 and
                                 int(p[0]) > 180) >= 4

    if not corners_are_checker and not np.any(bg_mask):
        # This image doesn't seem to have a checkerboard background
        # Just copy it as-is
        img.save(output_path)
        return False

    # If very few edge labels found, expand to all checkerboard pixels
    # that form large connected regions (> 100 pixels)
    if bg_mask.sum() < 100 and corners_are_checker:
        for label_id in range(1, num_features + 1):
            region = labeled == label_id
            if region.sum() > 50:
                bg_mask |= region

    # Apply transparency
    alpha = data[:,:,3].copy()
    alpha[bg_mask] = 0

    # Also soften edges slightly for anti-aliasing
    # Find pixels adjacent to the background mask that are semi-checkerboard
    from scipy.ndimage import binary_dilation
    edge_region = binary_dilation(bg_mask, iterations=1) & ~bg_mask

    # For edge pixels that are somewhat grey, reduce alpha
    edge_grey = edge_region & is_grey & (r > 160)
    alpha[edge_grey] = np.clip(alpha[edge_grey].astype(int) - 100, 0, 255).astype(np.uint8)

    data[:,:,3] = alpha

    result = Image.fromarray(data)
    result.save(output_path)
    return True


def process_directory(input_dir, process_subdirs=True):
    """Process all PNG images in a directory."""
    count = 0
    for root, dirs, files in os.walk(input_dir):
        for f in files:
            if f.lower().endswith('.png'):
                filepath = os.path.join(root, f)
                print(f"Processing: {filepath}")
                try:
                    fixed = remove_checkerboard(filepath, filepath)  # overwrite in-place
                    if fixed:
                        count += 1
                        print(f"  -> Fixed transparency")
                    else:
                        print(f"  -> No checkerboard detected, skipped")
                except Exception as e:
                    print(f"  -> ERROR: {e}")
    return count


if __name__ == '__main__':
    # Process all asset catalog images
    assets_dir = '/Users/ssddgreg/game/GemMineQuest/Assets.xcassets'

    # Process each category
    categories = [
        'Gems', 'Specials', 'Blockers', 'Icons', 'Boosters', 'UI',
        'Buttons', 'Character', 'Backgrounds', 'LevelMap', 'Tiles', 'Particles'
    ]

    total = 0
    for cat in categories:
        cat_dir = os.path.join(assets_dir, cat)
        if os.path.exists(cat_dir):
            print(f"\n=== Processing {cat} ===")
            total += process_directory(cat_dir)

    print(f"\nDone! Fixed {total} images.")
