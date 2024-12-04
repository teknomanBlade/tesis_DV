using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TriggerLightning : MonoBehaviour
{

    public float timeBetweenZapBundles = 1.5f;

    public int zapAmounts = 3;
    public float delayBetweenZaps = 0.2f;

    public ElectricityArc[] electricityArcs;

    private void Start()
    {
        StartZaps();
    }
    public void StartZaps() 
    {
        StartCoroutine(ZapTimer());
    }
    IEnumerator ZapTimer()
    {
        while (true)
        {
            if (timeBetweenZapBundles <= 0f || timeBetweenZapBundles > 10f)
                timeBetweenZapBundles = 1.5f;

            if (delayBetweenZaps <= 0f || delayBetweenZaps > 3f)
                delayBetweenZaps = 0.2f;

            yield return new WaitForSeconds(timeBetweenZapBundles);

            WaitForSeconds delay = new WaitForSeconds(delayBetweenZaps);

            for (int i = 0; i < zapAmounts; i++)
            {
                for (int j = 0; j < electricityArcs.Length; j++)
                {
                    if (electricityArcs[j] != null)
                    {
                        electricityArcs[j].Zap();
                    }
                }
                yield return delay;

            }
        }
    }
}
