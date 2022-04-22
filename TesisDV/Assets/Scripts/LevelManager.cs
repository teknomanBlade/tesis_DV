using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LevelManager : MonoBehaviour
{
    public delegate void LevelDelegate();
    public CraftingRecipe craftingRecipe;
    public bool playing = true;
    public bool inRound = false;

    private void Start()
    {
        craftingRecipe.RestoreBuildAmount();
    }

    private void Update()
    {

    }

    public void EndRound()
    {
        inRound = false;
    }

    public void WinGame()
    {
        Debug.Log("You Win!");
    }

    public void LoseGame()
    {
        playing = false;
        Debug.Log("Loser");
    }
}
