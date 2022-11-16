using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Letter : Item
{
    private Animator _anim;
    [SerializeField]
    private GameObject letterCanvas;
    private bool IsOpened { get; set; }

    void Awake()
    {
        IsOpened = true;
        _anim = GetComponent<Animator>();
        itemType = ItemType.Interactable;
    }

    public void ShowLetter()
    {
        //letterCanvas.SetActive(true);

        var screenLetter = Instantiate(Resources.Load<LetterScreen>("LetterCanvas"));
        screenLetter.OnCloseLetterEvent += Interact;
        ScreenManager.Instance.Push(screenLetter);
    }
    public void HideLetter()
    {
        //letterCanvas.SetActive(false);
    }

    public override void Interact()
    {
        if (IsOpened)
        {
            _anim.SetBool("IsOpened", true);
            IsOpened = false;
        }
        else
        {
            _anim.SetBool("IsOpened", false);
            IsOpened = true;
        }
    }
    public void OpenLetterSound()
    {
        GameVars.Values.soundManager.PlaySoundAtPoint("LetterOpen", transform.position, 0.8f);
    }
    public void CloseLetterSound()
    {
        GameVars.Values.soundManager.PlaySoundAtPoint("LetterClose", transform.position, 0.8f);
    }
}
