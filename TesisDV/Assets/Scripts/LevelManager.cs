using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LevelManager : MonoBehaviour
{
    public delegate void LevelDelegate();
    public event LevelDelegate OnStartRound;
    public event LevelDelegate OnEndRound;

    public List<Vector3> path;

    int roundEnemies = 0;
    int maxEnemies = 24;
    int startingRound = 0;
    int round = 1;
    int winRound = 10;

    private void Start()
    {
        OnStartRound += StartRound;
        OnEndRound += EndRound;
    }

    public void BeginGame()
    {
        StartCoroutine("BeginGameCoroutine");
    }

    public void StartRound()
    {
        roundEnemies = CalculateRoundEnemies();
    }

    public void EndRound()
    {
        if (round == 10) WinGame();
        else round++;
    }

    public int CalculateRoundEnemies()
    {

        roundEnemies = roundEnemies + round;
        if (roundEnemies >= maxEnemies) return maxEnemies;
        return roundEnemies;
    }

    public void WinGame()
    {

    }

    IEnumerator BeginGameCoroutine()
    {
        yield return new WaitForSeconds(3f);
        OnStartRound?.Invoke();
    }


}
