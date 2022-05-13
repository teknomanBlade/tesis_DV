using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class CatDistanceBar : MonoBehaviour
{
    private Slider _mySlider;
    private float _maxDistance;
    private float _currentDistance = 0;
    private Cat _cat;

    void Start()
    {
        _mySlider = GetComponent<Slider>();
        
        _maxDistance = GameVars.Values.GetCatDistance(); //54
        _mySlider.maxValue = _maxDistance;
        
        _currentDistance = _maxDistance;
        _mySlider.value = _currentDistance;
        
    }

    void Update()
    {
        _mySlider.value = GameVars.Values.GetCatDistance();
        Debug.Log(GameVars.Values.GetCatDistance());
    }
}
