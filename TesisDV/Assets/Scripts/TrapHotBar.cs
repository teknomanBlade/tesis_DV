using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TrapHotBar : MonoBehaviour
{
    [SerializeField] TrapSlot[] trapSlots;

    [SerializeField] private CanvasGroup _myCanvasGroup;
    private float fadeDelay = 1.1f;
    private bool isFaded;
    private float _showingNotificationDelay = 2.0f;

    private void Awake()
    {
        _myCanvasGroup = GetComponent<CanvasGroup>();
        isFaded = true;
    }

    public void Fade()
    {
        StartCoroutine(DoFade(_myCanvasGroup.alpha, 1));
        isFaded = !isFaded;
    }
    public IEnumerator DoFade(float start, float end)
    {
        float counter = 0f;

        while (counter < fadeDelay)
        {
            counter += Time.deltaTime;
            _myCanvasGroup.alpha = Mathf.Lerp(start, end, counter / fadeDelay);

            yield return null;
        }
    }

    public void CheckRecipeRequirements(Inventory inventory)
    {
        if (GameVars.Values.BaseballLauncher.HasBaseballTrapItems(inventory))
        {
            if(isFaded)
            {
                Fade();
            }
            trapSlots[0].ActivateImage();
            Invoke("ShowNotificationSlot1", _showingNotificationDelay);
        }
        else
        {
            trapSlots[0].DeactivateImage();
        }

        if (GameVars.Values.BaseballLauncher.HasTVTrapItems(inventory))
        {
            if (isFaded)
            {
                Fade();
            }
            trapSlots[1].ActivateImage();
            Invoke("ShowNotificationSlot2", _showingNotificationDelay);
        }
        else
        {
            trapSlots[1].DeactivateImage();
        }

        if (GameVars.Values.SlowTrap.HasSlowTrapItems(inventory))
        {
            if(isFaded)
            {
                Fade();
            }
            trapSlots[2].ActivateImage();
            Invoke("ShowNotificationSlot3", _showingNotificationDelay);
        }
        else
        {
            trapSlots[2].DeactivateImage();
        }

        if (GameVars.Values.SlowTrap.HasNailFiringMachineItems(inventory))
        {
            if(isFaded)
            {
                Fade();
            }
            trapSlots[3].ActivateImage();
            Invoke("ShowNotificationSlot4", _showingNotificationDelay);
        }
        else
        {
            trapSlots[3].DeactivateImage();
        }

        if (GameVars.Values.SlowTrap.HasElectricTrapItems(inventory))
        {
            if(isFaded)
            {
                Fade();
            }
            trapSlots[4].ActivateImage();
            Invoke("ShowNotificationSlot5", _showingNotificationDelay);
        }
        else
        {
            trapSlots[4].DeactivateImage();
        }
    }

    public void ShowNotificationSlot1()
    {
        GameVars.Values.ShowNotification("Baseball Tower. Press 1 to create, Double Tap 1 to see description.");
    }
    public void ShowNotificationSlot2()
    {
        GameVars.Values.ShowNotification("Microwave Pusher. Press 2 to create, Double Tap 2 to see description.");
    }
    public void ShowNotificationSlot3()
    {
        GameVars.Values.ShowNotification("Tar Slowing Trap. Press 3 to create, Double Tap 3 to see description.");
    }
    public void ShowNotificationSlot4()
    {
        GameVars.Values.ShowNotification("Nail Firing Tower. Press 4 to create, Double Tap 4 to see description.");
    }
    public void ShowNotificationSlot5()
    {
        GameVars.Values.ShowNotification("Electric Tower. Press 5 to create, Double Tap 5 to see description.");
    }
}
