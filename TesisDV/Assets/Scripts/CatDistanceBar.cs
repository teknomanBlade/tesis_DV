using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class CatDistanceBar : MonoBehaviour
{
    private Slider _mySlider;
    private float _maxDistance;
    private float _currentDistance = 0;
    private Image _fillImage;
    public GameObject Fill;
    public float _valueToChange { get; private set; }
    

    void Start()
    {
        _mySlider = GetComponent<Slider>();
        _fillImage = Fill.GetComponent<Image>();
        _maxDistance = GameVars.Values.GetCatDistance(); //54
        _mySlider.maxValue = 54; //_maxDistance;
        _mySlider.minValue = 5f;
        _currentDistance = _maxDistance;
        _mySlider.value = _currentDistance;
        
    }
    IEnumerator LerpColor(float endValue, float duration)
    {
        float time = 0;
        float startValue = _valueToChange;

        while (time < duration)
        {
            _valueToChange = Mathf.Lerp(startValue, endValue, time / duration);
            time += Time.deltaTime;

            _fillImage.color = Color.Lerp(Color.green, Color.red, _valueToChange);
            yield return null;
        }


        _valueToChange = endValue;
    }
    void Update()
    {
        _mySlider.value = GameVars.Values.GetCatDistance();
        if (_mySlider.value < 20f)
        {
            StartCoroutine(LerpColor(1f,1.5f)); 
        }
        else
        {
            _fillImage.color = Color.green;
        }
    }
}
