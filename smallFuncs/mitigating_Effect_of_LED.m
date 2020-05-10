function Image = mitigating_Effect_of_LED(Image)
    MAX_withoutLED = max(max(Image(1:300,:)));
    Image(Image > MAX_withoutLED) = MAX_withoutLED;
end