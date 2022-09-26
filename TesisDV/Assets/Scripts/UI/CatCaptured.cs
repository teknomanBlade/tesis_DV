using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class CatCaptured : MonoBehaviour
{
    public Sprite catCapturedSprite;
    public GameObject catImage;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    public void SetCapturedCatImage()
    {
        catImage.GetComponent<Image>().sprite = catCapturedSprite;
    }
}
