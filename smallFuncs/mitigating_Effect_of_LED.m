function Image = mitigating_Effect_of_LED(Image, background)


    MAX_withoutLED = max(Image(background == 0));
    Image(Image > MAX_withoutLED) = MAX_withoutLED;
end