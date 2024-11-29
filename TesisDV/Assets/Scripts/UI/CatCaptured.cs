using UnityEngine;
using UnityEngine.UI;

public class CatCaptured : MonoBehaviour
{
    private Animator _animator;
    public Sprite catReleasedSprite;
    public Sprite catCapturedSprite;
    public GameObject catImage;
    public Cat Owner;
    public delegate void OnCapturedCatChangeDelegate(bool isCaptured);
    public event OnCapturedCatChangeDelegate OnCapturedCatChange;

    void Start()
    {
        //GameVars.Values.OnCapturedCatChange += CatCaptureChanged;
        Owner = GameVars.Values.Cat;
        OnCapturedCatChange += CatCaptureChanged;
        _animator = GetComponent<Animator>();
    }

    public void CapturedCatChangeUI(bool isCaptured) 
    {
        OnCapturedCatChange(isCaptured);
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
