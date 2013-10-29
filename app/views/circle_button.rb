class CircleButton < UIButton

  attr_reader :nel_baule

  def setColor(color)
    @color = color
  end

  def nel_baule=(nel_baule)
    @nel_baule = nel_baule
    self.setNeedsDisplay
  end

  def drawRect(rect)

    #  baseColor = UIColor.colorWithRed( 0.667, green:0.667, blue:0.667, alpha:1)
     
    ## General Declarations
    context = UIGraphicsGetCurrentContext()

    if nel_baule == 1
      ## Color Declarations
      baseColor = @color || UIColor.colorWithRed( 0.667, green:0.667, blue:0.667, alpha:1)
    else
      baseColor = UIColor.colorWithRed( 0.667, green:0.667, blue:0.667, alpha:1)
    end


    baseColorH  = Pointer.new(:float, 1)
    baseColorS  = Pointer.new(:float, 1)
    baseColorBr = Pointer.new(:float, 1)
    baseColorAl = Pointer.new(:float, 1)
    baseColor.getHue baseColorH, saturation: baseColorS, brightness: baseColorBr, alpha: baseColorAl

    circleOuterColor = UIColor.colorWithHue baseColorH[0], saturation: baseColorS[0], brightness: 0.5, alpha: baseColorAl[0]

    if nel_baule == 1
      ## Shadow Declarations
      shadow = circleOuterColor
      shadowOffset = CGSizeMake(0.1, 1.1)
      shadowBlurRadius = 1.5
    end

    ## OvalOuter Drawing
    ovalOuterPath = UIBezierPath.bezierPathWithOvalInRect CGRectMake(8, 8, 25, 25)
    circleOuterColor.setStroke
    ovalOuterPath.lineWidth = 1
    ovalOuterPath.stroke

    if nel_baule == 1

      ## OvalInner Drawing
      ovalInnerPath = UIBezierPath.bezierPathWithOvalInRect CGRectMake(12, 12, 17, 17)
      baseColor.setFill
      ovalInnerPath.fill

      ### OvalInner Inner Shadow
      ovalInnerBorderRect = CGRectInset(ovalInnerPath.bounds, -shadowBlurRadius, -shadowBlurRadius)
      ovalInnerBorderRect = CGRectOffset(ovalInnerBorderRect, -shadowOffset.width, -shadowOffset.height)
      ovalInnerBorderRect = CGRectInset(CGRectUnion(ovalInnerBorderRect, ovalInnerPath.bounds), -1, -1)

      ovalInnerNegativePath = UIBezierPath.bezierPathWithRect(ovalInnerBorderRect)
      ovalInnerNegativePath.appendPath(ovalInnerPath)
      ovalInnerNegativePath.usesEvenOddFillRule = true

      CGContextSaveGState(context)
      # {      
        xOffset = shadowOffset.width + ovalInnerBorderRect.size.width.ceil
        yOffset = shadowOffset.height
        
        CGContextSetShadowWithColor(context,
              CGSizeMake(xOffset + 0.1, yOffset + 0.1),
              shadowBlurRadius,
              shadow.CGColor)

        ovalInnerPath.addClip
        transform = CGAffineTransformMakeTranslation(-ovalInnerBorderRect.size.width.ceil, 0)
        ovalInnerNegativePath.applyTransform(transform)
        UIColor.grayColor.setFill
        ovalInnerNegativePath.fill
      # }
      CGContextRestoreGState(context)
    end

  end


end