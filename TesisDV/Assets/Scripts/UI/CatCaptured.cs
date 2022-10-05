using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class CatCaptured : MonoBehaviour
{
    private Animator _animator;
    public Sprite catReleasedSprite;
    public Sprite catCapturedSprite;
    public GameObject catImage;

    void Start()
    {
        GameVars.Values.OnCapturedCatChange += CatCaptureChanged;
        _animator = GetComponent<Animator>();

    }

    public void SetAnimatorCaptureBool(bool isCaptured)
    {
        _animator.SetBool("IsCaptured", isCaptured);
    }

    private void CatCaptureChanged(bool isCaptured)
    {
        if (isCaptured)
        {
            SetAnimatorCaptureBool(isCaptured);
            SetCapturedCatImage();
        }
        else
        {
            SetAnimatorCaptureBool(isCaptured);
            SetReleasedCatImage();
        }
    }

    public void SetCapturedCatImage() //Esto se llama por la animacion.
    {
        catImage.GetComponent<Image>().sprite = catCapturedSprite;
    }
    public void SetReleasedCatImage() //Esto se llama por 
    {
        catImage.GetComponent<Image>().sprite = catReleasedSprite;
    }
}
